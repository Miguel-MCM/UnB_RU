class User < ApplicationRecord
  normalizes :matricula, with: ->(matricula) { matricula.strip }

  validates :nome, presence: true
  validates :matricula, presence: true, uniqueness: true, format: { with: /\A\d+\z/, allow_blank: true }
  validates :password, presence: true, confirmation: true
end
