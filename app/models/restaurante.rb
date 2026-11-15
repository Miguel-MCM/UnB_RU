class Restaurante < ApplicationRecord
  has_many :catracas, -> { order(:nome) }, dependent: :destroy
  has_many :turnos, -> { ordenados }, dependent: :destroy
  has_many :acessos, dependent: :nullify

  normalizes :nome, with: ->(nome) { nome.squish }

  validates :nome, presence: true, uniqueness: true

  scope :ordenados, -> { order(:nome) }
  scope :com_turnos, -> { where(id: Turno.select(:restaurante_id)) }

  # O ponto de acesso só precisa ser configurado quando há restaurantes para escolher.
  def self.selecao_obrigatoria?
    exists?
  end
end
