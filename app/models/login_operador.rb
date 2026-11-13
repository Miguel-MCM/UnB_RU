class LoginOperador
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :matricula, :string
  attribute :password, :string

  validates :matricula, :password, presence: { message: "Campo obrigatório" }

  def funcionario
    Funcionario.autenticar(matricula, password) if valid?
  end
end
