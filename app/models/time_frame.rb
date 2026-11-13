class TimeFrame < ApplicationRecord
  include HorarioEmMinutos

  belongs_to :turno

  horario :hora_inicio, :hora_fim

  validates :numero, :hora_inicio_min, :hora_fim_min, presence: true
end
