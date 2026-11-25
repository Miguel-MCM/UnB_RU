# Catraca de entrada de um restaurante. O nome é normalizado (espaços) e único dentro do
# restaurante. Ao ser removida, os acessos registrados nela ficam sem catraca.
class Catraca < ApplicationRecord
  belongs_to :restaurante
  has_many :acessos, dependent: :nullify

  normalizes :nome, with: ->(nome) { nome.squish }

  validates :nome, presence: true, uniqueness: { scope: :restaurante_id }
end
