# Inscrição gratuita de um estudante no sorteio do FastPass de um turno,
# escolhendo um único time-frame por turno e dia.
class InscricaoFastpass < ApplicationRecord
  belongs_to :user
  belongs_to :sorteio
  belongs_to :time_frame
  has_many :acessos, dependent: :nullify
  has_one :notificacao, dependent: :destroy

  enum :status, {
    inscrito: "inscrito",
    sorteado: "sorteado",
    nao_sorteado: "nao_sorteado",
    utilizado: "utilizado"
  }

  validate :inscricoes_abertas, on: :create
  validate :um_time_frame_por_turno, on: :create
  validate :time_frame_do_turno_do_sorteio, on: :create

  scope :do_dia, ->(data = Date.current) { joins(:sorteio).where(sorteios: { data_refeicao: data }) }
  scope :do_turno, ->(turno) { joins(:sorteio).where(sorteios: { turno_id: turno }) }
  scope :contempladas, -> { where(status: %w[sorteado utilizado]) }
  scope :com_resultado, -> { where(status: %w[sorteado nao_sorteado utilizado]) }
  scope :sem_notificacao, -> { where.missing(:notificacao) }
  scope :do_restaurante, ->(restaurante) { joins(sorteio: :turno).where(turnos: { restaurante_id: restaurante }) }

  # Inscrição contemplada no sorteio (sorteada ou já utilizada) do estudante no
  # restaurante e no dia do momento. Prefere a do time-frame que cobre o
  # momento, depois a do turno que cobre o momento e, por fim, a de horário
  # mais próximo — assim quem chega fora do time-frame é identificado como tal.
  # Caso de borda: entre dois turnos, a mais próxima pode ser uma inscrição já
  # utilizada, e a leitura resulta em "FastPass já foi utilizado".
  def self.contemplada_de(user, restaurante, momento)
    minutos = HorarioEmMinutos.minutos_do(momento)
    inscricoes = where(user:).do_dia(momento.to_date).do_restaurante(restaurante).contempladas
                   .includes(:time_frame, sorteio: :turno).to_a

    inscricoes.find { |inscricao| inscricao.time_frame.cobre?(minutos) } ||
      inscricoes.find { |inscricao| inscricao.sorteio.turno.cobre?(minutos) } ||
      inscricoes.min_by { |inscricao| inscricao.time_frame.distancia_de(minutos) }
  end

  # Inscreve o estudante no sorteio do dia do turno do time-frame. Não cobra
  # nada. O turno fica travado para não concorrer com a redivisão dos
  # time-frames. Retorna a inscrição: persistida, ou com os erros em #errors.
  def self.inscrever!(user:, time_frame:)
    inscricao = nil
    time_frame.turno.with_lock do
      inscricao = new(user:, time_frame:, sorteio: Sorteio.do_dia!(time_frame.turno))
      inscricao.save
    end
    inscricao
  rescue ActiveRecord::RecordNotUnique
    inscricao.errors.add(:base, :um_time_frame_por_turno)
    inscricao
  end

  # Notifica o estudante do resultado do sorteio (contemplado se sorteada ou já
  # utilizada). Idempotente: se a inscrição já foi notificada, não faz nada e
  # retorna a notificação existente.
  def notificar!(agora = Time.current)
    notificacao || create_notificacao!(user:, tipo: tipo_da_notificacao, mensagem: mensagem_da_notificacao, enviada_em: agora)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    reload.notificacao || raise
  end

  def contemplada?
    sorteado? || utilizado?
  end

  private
    def tipo_da_notificacao
      contemplada? ? :contemplado : :nao_contemplado
    end

    def mensagem_da_notificacao
      I18n.t("notificacoes.#{tipo_da_notificacao}",
             turno: sorteio.turno.nome, data: I18n.l(sorteio.data_refeicao, format: "%d/%m/%Y"), horario: time_frame.horario)
    end

    def inscricoes_abertas
      errors.add(:base, :inscricoes_encerradas) if sorteio && !sorteio.inscricoes_abertas?
    end

    def um_time_frame_por_turno
      return unless user && sorteio

      errors.add(:base, :um_time_frame_por_turno) if InscricaoFastpass.exists?(user:, sorteio:)
    end

    def time_frame_do_turno_do_sorteio
      return unless time_frame && sorteio

      errors.add(:base, :time_frame_de_outro_turno) if time_frame.turno_id != sorteio.turno_id
    end
end
