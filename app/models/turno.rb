# Turno de refeição de um restaurante (ex.: almoço, jantar), com janela de
# horário sem sobreposição e divisão opcional em time-frames para o FastPass.
class Turno < ApplicationRecord
  include HorarioEmMinutos

  belongs_to :restaurante
  has_many :sorteios, dependent: :destroy
  has_many :time_frames, -> { order(:numero) }, dependent: :destroy

  horario :hora_inicio, :hora_fim

  normalizes :nome, with: ->(nome) { nome.squish }

  validates :nome, presence: true, uniqueness: { scope: :restaurante_id }
  validates :hora_inicio_min, :hora_fim_min, presence: true
  validates :duracao_time_frame_min, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :fim_depois_do_inicio
  validate :sem_sobreposicao
  validate :duracao_cabe_no_turno

  scope :ordenados, -> { order(:hora_inicio_min) }
  scope :sobrepostos_a, ->(turno) do
    where(restaurante_id: turno.restaurante_id)
      .where(hora_inicio_min: ...turno.hora_fim_min)
      .where("hora_fim_min > ?", turno.hora_inicio_min)
      .where.not(id: turno.id)
  end

  # Turnos cujo sorteio já deve ter sido realizado (1 hora antes do início)
  # no minuto do dia `minutos`.
  scope :com_sorteio_ate, ->(minutos) { where(hora_inicio_min: ..(minutos + Sorteio::ANTECEDENCIA_MIN)) }

  # Calcula a duração total do turno em minutos.
  #
  # Argumentos:: nenhum.
  # Retorno:: +Integer+ com a diferença em minutos entre fim e início quando
  #           ambos estão informados; +nil+ caso algum horário esteja ausente.
  # Efeitos colaterais:: nenhum.
  def duracao_total_min
    hora_fim_min - hora_inicio_min if horarios_informados?
  end

  # Redivide o turno em time-frames com a duração informada, sob lock exclusivo
  # do registro. Se já houver inscrições no FastPass ou se a duração for
  # inválida, nada é alterado no banco e os erros ficam em +#errors+.
  #
  # Argumentos:: +minutos+ (Integer/String) com a duração desejada de cada
  #              time-frame em minutos.
  # Retorno:: +true+ quando os time-frames são recriados com sucesso; +false+
  #           quando há inscrições existentes ou a duração falha na validação.
  # Efeitos colaterais:: abre transação com lock no +Turno+, atualiza
  #                      +duracao_time_frame_min+, remove os +TimeFrame+ antigos
  #                      e cria os novos no banco em caso de sucesso; restaura o
  #                      atributo em memória e preenche +#errors+ em caso de falha.
  def dividir_em_time_frames!(minutos)
    with_lock do
      if possui_inscricoes?
        errors.add(:base, :possui_inscricoes)
        false
      elsif update(duracao_time_frame_min: minutos)
        time_frames.delete_all
        criar_time_frames
        true
      else
        restore_attributes([ :duracao_time_frame_min ])
        false
      end
    end
  end

  # Verifica se algum time-frame do turno já possui inscrições no FastPass.
  #
  # Argumentos:: nenhum.
  # Retorno:: +true+ se existir ao menos uma +InscricaoFastpass+ vinculada aos
  #           time-frames do turno; +false+ caso contrário.
  # Efeitos colaterais:: nenhum (apenas consulta ao banco de dados).
  def possui_inscricoes?
    time_frames.joins(:inscricoes_fastpass).exists?
  end

  private
    # Indica se ambos os horários de início e fim foram preenchidos.
    #
    # Argumentos:: nenhum.
    # Retorno:: +true+ quando +hora_inicio_min+ e +hora_fim_min+ estão
    #           presentes; +false+ caso contrário.
    # Efeitos colaterais:: nenhum.
    def horarios_informados?
      hora_inicio_min.present? && hora_fim_min.present?
    end

    # Gera e persiste os time-frames sequenciais cobrindo o intervalo do turno,
    # ajustando o último caso a divisão não seja exata.
    #
    # Argumentos:: nenhum.
    # Retorno:: o +Enumerator+ percorrido durante a criação.
    # Efeitos colaterais:: insere novos registros de +TimeFrame+ no banco de dados.
    def criar_time_frames
      (hora_inicio_min...hora_fim_min).step(duracao_time_frame_min).with_index(1) do |inicio, numero|
        time_frames.create!(numero:, hora_inicio_min: inicio, hora_fim_min: [ inicio + duracao_time_frame_min, hora_fim_min ].min)
      end
    end

    # Valida que o horário de término é estritamente posterior ao de início.
    #
    # Argumentos:: nenhum.
    # Retorno:: +ActiveModel::Error+ adicionado ou +nil+.
    # Efeitos colaterais:: adiciona erro em +errors[:base]+ quando
    #                      +hora_fim_min <= hora_inicio_min+.
    def fim_depois_do_inicio
      errors.add(:base, :fim_antes_do_inicio) if horarios_informados? && hora_fim_min <= hora_inicio_min
    end

    # Valida que não há sobreposição de horário com outro turno do restaurante.
    #
    # Argumentos:: nenhum.
    # Retorno:: +ActiveModel::Error+ adicionado ou +nil+.
    # Efeitos colaterais:: consulta o banco e adiciona erro em +errors[:base]+
    #                      citando o turno conflitante quando há sobreposição.
    def sem_sobreposicao
      return unless horarios_informados? && restaurante_id

      conflitante = Turno.sobrepostos_a(self).first
      errors.add(:base, :conflito, turno: conflitante.nome) if conflitante
    end

    # Valida que a duração do time-frame não ultrapassa a duração total do turno.
    #
    # Argumentos:: nenhum.
    # Retorno:: +ActiveModel::Error+ adicionado ou +nil+.
    # Efeitos colaterais:: adiciona erro em +errors[:base]+ quando
    #                      +duracao_time_frame_min > duracao_total_min+.
    def duracao_cabe_no_turno
      return unless duracao_time_frame_min && duracao_total_min&.positive?

      errors.add(:base, :duracao_maior_que_turno) if duracao_time_frame_min > duracao_total_min
    end
end
