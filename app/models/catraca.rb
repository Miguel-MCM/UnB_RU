class Catraca < ApplicationRecord
  belongs_to :restaurante

  normalizes :nome, with: ->(nome) { nome.squish }

  validates :nome, presence: true, uniqueness: { scope: :restaurante_id }
end
