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

  def duracao_total_min
    hora_fim_min - hora_inicio_min if horarios_informados?
  end

  # Redivide o turno em time-frames de `minutos`, com o turno travado (with_lock
  # recarrega o registro e abre a transação). Se a duração for inválida ou se
  # algum time-frame já tiver inscrições no FastPass, nada é alterado e retorna
  # false (os erros ficam em #errors).
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

  def possui_inscricoes?
    time_frames.joins(:inscricoes_fastpass).exists?
  end

  private
    def horarios_informados?
      hora_inicio_min.present? && hora_fim_min.present?
    end

    def criar_time_frames
      (hora_inicio_min...hora_fim_min).step(duracao_time_frame_min).with_index(1) do |inicio, numero|
        time_frames.create!(numero:, hora_inicio_min: inicio, hora_fim_min: [ inicio + duracao_time_frame_min, hora_fim_min ].min)
      end
    end

    def fim_depois_do_inicio
      errors.add(:base, :fim_antes_do_inicio) if horarios_informados? && hora_fim_min <= hora_inicio_min
    end

    def sem_sobreposicao
      return unless horarios_informados? && restaurante_id

      conflitante = Turno.sobrepostos_a(self).first
      errors.add(:base, :conflito, turno: conflitante.nome) if conflitante
    end

    def duracao_cabe_no_turno
      return unless duracao_time_frame_min && duracao_total_min&.positive?

      errors.add(:base, :duracao_maior_que_turno) if duracao_time_frame_min > duracao_total_min
    end
end
