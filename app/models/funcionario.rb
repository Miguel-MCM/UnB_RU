class Funcionario < ApplicationRecord
  include Autenticavel

  normalizes :matricula, with: ->(matricula) { matricula.strip }

  validates :nome, presence: true
  validates :matricula, presence: true, uniqueness: true
  validates :password, presence: true
end
