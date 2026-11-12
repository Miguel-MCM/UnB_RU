class Restaurante < ApplicationRecord
  has_many :catracas, -> { order(:nome) }, dependent: :destroy

  normalizes :nome, with: ->(nome) { nome.squish }

  validates :nome, presence: true, uniqueness: true

  scope :ordenados, -> { order(:nome) }
end
