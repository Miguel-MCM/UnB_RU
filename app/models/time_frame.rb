# Subintervalo sequencial de horário dentro de um +Turno+, no qual estudantes
# podem se inscrever para concorrer ao FastPass.
class TimeFrame < ApplicationRecord
  include HorarioEmMinutos

  belongs_to :turno
  has_many :inscricoes_fastpass, dependent: :destroy

  horario :hora_inicio, :hora_fim

  validates :numero, :hora_inicio_min, :hora_fim_min, presence: true
end
