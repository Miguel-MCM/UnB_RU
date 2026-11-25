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

  # Busca a inscrição contemplada no sorteio (sorteada ou já utilizada) do
  # estudante no restaurante e no dia do momento informado. Prefere a do
  # time-frame que cobre o momento, depois a do turno que cobre o momento e, por
  # fim, a de horário mais próximo — assim quem chega fora do time-frame é
  # identificado como tal. Caso de borda: entre dois turnos, a mais próxima pode
  # ser uma inscrição já utilizada, e a leitura resulta em "FastPass já foi
  # utilizado".
  #
  # Argumentos:: +user+ (User), +restaurante+ (Restaurante) e +momento+
  #              (Time/ActiveSupport::TimeWithZone) da leitura na catraca.
  # Retorno:: a +InscricaoFastpass+ contemplada mais adequada ao momento, ou
  #           +nil+ quando o estudante não possui inscrição contemplada no dia e
  #           restaurante informados.
  # Efeitos colaterais:: nenhum (apenas leitura no banco de dados).
  def self.contemplada_de(user, restaurante, momento)
    minutos = HorarioEmMinutos.minutos_do(momento)
    inscricoes = contempladas_do_dia(user, restaurante, momento.to_date)

    selecionar_por_horario(inscricoes, minutos)
  end

  # Carrega as inscrições contempladas do estudante em um restaurante e data.
  #
  # Argumentos:: +user+ (User), +restaurante+ (Restaurante) e +data+ (Date).
  # Retorno:: +Array<InscricaoFastpass>+ com associações de +time_frame+,
  #           +sorteio+ e +turno+ pré-carregadas (vazio se não houver registros).
  # Efeitos colaterais:: nenhum (apenas leitura no banco de dados).
  def self.contempladas_do_dia(user, restaurante, data)
    where(user:).do_dia(data).do_restaurante(restaurante).contempladas
      .includes(:time_frame, sorteio: :turno).to_a
  end

  # Seleciona, entre as inscrições contempladas, a que melhor corresponde ao
  # minuto do dia informado (prioridade: time-frame, turno, menor distância).
  #
  # Argumentos:: +inscricoes+ (Array<InscricaoFastpass>) e +minutos+ (Integer)
  #              desde a meia-noite.
  # Retorno:: a +InscricaoFastpass+ selecionada, ou +nil+ se +inscricoes+
  #           estiver vazio.
  # Efeitos colaterais:: nenhum.
  def self.selecionar_por_horario(inscricoes, minutos)
    inscricoes.find { |inscricao| inscricao.cobre_momento?(minutos) } ||
      inscricoes.find { |inscricao| inscricao.turno_cobre_momento?(minutos) } ||
      inscricoes.min_by { |inscricao| inscricao.distancia_em_minutos(minutos) }
  end
  private_class_method :contempladas_do_dia, :selecionar_por_horario

  # Inscreve o estudante no sorteio do dia do turno do time-frame, sem cobrança.
  # O turno é travado para evitar concorrência com a redivisão dos time-frames.
  #
  # Argumentos:: +user:+ (User) e +time_frame:+ (TimeFrame) escolhido.
  # Retorno:: +InscricaoFastpass+ persistida quando válida, ou não persistida
  #           com os erros preenchidos em +#errors+ quando recusada.
  # Efeitos colaterais:: adquire lock no registro do +Turno+, pode criar o
  #                      +Sorteio+ do dia e grava a +InscricaoFastpass+ no banco
  #                      quando as validações passam.
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

  # Notifica o estudante sobre o resultado do sorteio (contemplado se sorteada
  # ou já utilizada). É idempotente: se já houver notificação, devolve a
  # existente sem duplicar.
  #
  # Argumentos:: +agora+ (Time/ActiveSupport::TimeWithZone, opcional; padrão
  #              +Time.current+) usado como data/hora de envio.
  # Retorno:: a +Notificacao+ existente ou recém-criada; propaga exceção
  #           (+ActiveRecord::RecordNotUnique+ ou +ActiveRecord::RecordInvalid+)
  #           se a criação falhar sem existir notificação prévia no banco.
  # Efeitos colaterais:: grava um registro de +Notificacao+ no banco quando a
  #                      inscrição ainda não foi notificada; pode recarregar a
  #                      inscrição em caso de corrida.
  def notificar!(agora = Time.current)
    notificacao || create_notificacao!(user:, tipo: tipo_da_notificacao, mensagem: mensagem_da_notificacao, enviada_em: agora)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    reload.notificacao || raise
  end

  # Indica se a inscrição foi contemplada no sorteio (sorteada ou já utilizada).
  #
  # Argumentos:: nenhum.
  # Retorno:: +true+ quando o status é +sorteado+ ou +utilizado+; +false+ caso
  #           contrário.
  # Efeitos colaterais:: nenhum.
  def contemplada?
    sorteado? || utilizado?
  end

  # Verifica se o time-frame desta inscrição cobre o minuto informado.
  #
  # Argumentos:: +minutos+ (Integer) contados a partir da meia-noite.
  # Retorno:: +true+ se +minutos+ está dentro do intervalo do time-frame;
  #           +false+ caso contrário.
  # Efeitos colaterais:: nenhum.
  def cobre_momento?(minutos)
    time_frame.cobre?(minutos)
  end

  # Verifica se o turno do sorteio desta inscrição cobre o minuto informado.
  #
  # Argumentos:: +minutos+ (Integer) contados a partir da meia-noite.
  # Retorno:: +true+ se +minutos+ está dentro do intervalo do turno; +false+
  #           caso contrário.
  # Efeitos colaterais:: nenhum.
  def turno_cobre_momento?(minutos)
    sorteio.turno.cobre?(minutos)
  end

  # Calcula a distância em minutos entre o minuto informado e o time-frame.
  #
  # Argumentos:: +minutos+ (Integer) contados a partir da meia-noite.
  # Retorno:: +Integer+ não negativo com a distância em minutos (+0+ quando o
  #           time-frame cobre o momento).
  # Efeitos colaterais:: nenhum.
  def distancia_em_minutos(minutos)
    time_frame.distancia_de(minutos)
  end

  private
    # Determina o tipo da notificação conforme o resultado da inscrição.
    #
    # Argumentos:: nenhum.
    # Retorno:: +:contemplado+ quando +#contemplada?+ é verdadeiro;
    #           +:nao_contemplado+ caso contrário.
    # Efeitos colaterais:: nenhum.
    def tipo_da_notificacao
      contemplada? ? :contemplado : :nao_contemplado
    end

    # Monta o texto localizado da notificação com turno, data e horário.
    #
    # Argumentos:: nenhum.
    # Retorno:: +String+ com a mensagem traduzida via +I18n+.
    # Efeitos colaterais:: nenhum.
    def mensagem_da_notificacao
      I18n.t("notificacoes.#{tipo_da_notificacao}",
             turno: sorteio.turno.nome, data: I18n.l(sorteio.data_refeicao, format: "%d/%m/%Y"), horario: time_frame.horario)
    end

    # Valida se o sorteio ainda está com as inscrições abertas.
    #
    # Argumentos:: nenhum.
    # Retorno:: +ActiveModel::Error+ adicionado ou +nil+.
    # Efeitos colaterais:: adiciona erro em +errors[:base]+ quando as inscrições
    #                      estão encerradas.
    def inscricoes_abertas
      errors.add(:base, :inscricoes_encerradas) if sorteio && !sorteio.inscricoes_abertas?
    end

    # Valida que o estudante ainda não possui inscrição no mesmo sorteio/turno.
    #
    # Argumentos:: nenhum.
    # Retorno:: +ActiveModel::Error+ adicionado ou +nil+.
    # Efeitos colaterais:: consulta o banco e adiciona erro em +errors[:base]+
    #                      quando já existe inscrição do usuário no sorteio.
    def um_time_frame_por_turno
      return unless user && sorteio

      errors.add(:base, :um_time_frame_por_turno) if InscricaoFastpass.exists?(user:, sorteio:)
    end

    # Valida que o time-frame selecionado pertence ao mesmo turno do sorteio.
    #
    # Argumentos:: nenhum.
    # Retorno:: +ActiveModel::Error+ adicionado ou +nil+.
    # Efeitos colaterais:: adiciona erro em +errors[:base]+ quando há divergência
    #                      de turno.
    def time_frame_do_turno_do_sorteio
      return unless time_frame && sorteio

      errors.add(:base, :time_frame_de_outro_turno) if time_frame.turno_id != sorteio.turno_id
    end
end
