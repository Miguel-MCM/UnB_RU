class Funcionario < ApplicationRecord
  include Autenticavel

  has_many :acessos, dependent: :restrict_with_error

  normalizes :matricula, with: ->(matricula) { matricula.strip }

  validates :nome, presence: true
  validates :matricula, presence: true, uniqueness: true
  validates :password, presence: true
end
