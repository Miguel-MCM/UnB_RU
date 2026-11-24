# Formulário de login do operador na Aplicação de Controle. Não é gravado no
# banco: valida que matrícula e senha foram preenchidas e, se foram, procura o
# Funcionario correspondente.
class LoginOperador
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :matricula, :string
  attribute :password, :string

  validates :matricula, :password, presence: { message: "Campo obrigatório" }

  # Autentica o operador com as credenciais do formulário.
  #
  # Argumentos:: nenhum; usa +matricula+ e +password+.
  # Retorno:: o Funcionario quando os dois campos estão preenchidos e conferem;
  #           +nil+ quando falta algum campo ou as credenciais não conferem.
  # Efeitos colaterais:: preenche +errors+ com "Campo obrigatório" nos campos em
  #                      branco; nesse caso não consulta o banco.
  def funcionario
    Funcionario.autenticar(matricula, password) if valid?
  end
end
