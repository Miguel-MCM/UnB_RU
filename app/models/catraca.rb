class Catraca < ApplicationRecord
  belongs_to :restaurante
  has_many :acessos, dependent: :destroy

  normalizes :nome, with: ->(nome) { nome.squish }

  validates :nome, presence: true, uniqueness: { scope: :restaurante_id }
end
