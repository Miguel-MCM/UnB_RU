# Funcionário do restaurante que opera a Aplicação de Controle: lê as
# identificações dos estudantes no terminal da catraca. Com +administrador+
# marcado, também gerencia restaurantes, catracas, turnos e o relatório de
# acessos.
#
# Funcionários não se cadastram pelo site; entram em <tt>/operador/login</tt>
# com a matrícula SIAPE (ou o usuário SIGAA / gov.br) e a senha, verificadas
# por Autenticavel.autenticar. Não pode ser removido enquanto tiver leituras
# registradas, para preservar o histórico.
class Funcionario < ApplicationRecord
  include Autenticavel

  has_many :acessos, dependent: :restrict_with_error

  normalizes :matricula, with: ->(matricula) { matricula.strip }

  validates :nome, presence: true
  validates :matricula, presence: true, uniqueness: true
  validates :password, presence: true
end
