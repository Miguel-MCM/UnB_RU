require "rails_helper"

RSpec.describe User, type: :model do
  let(:atributos) do
    {
      nome: "João da Silva",
      matricula: "2023123456",
      password: "SenhaForte123",
      password_confirmation: "SenhaForte123"
    }
  end

  it "é válido com nome, matrícula e senhas iguais" do
    expect(User.new(atributos)).to be_valid
  end

  it "exige o nome" do
    user = User.new(atributos.merge(nome: ""))

    expect(user).not_to be_valid
    expect(user.errors[:nome]).to include("não pode ficar em branco")
  end

  it "exige a matrícula" do
    user = User.new(atributos.merge(matricula: ""))

    expect(user).not_to be_valid
    expect(user.errors[:matricula]).to include("não pode ficar em branco")
  end

  it "aceita apenas dígitos na matrícula" do
    user = User.new(atributos.merge(matricula: "2023-12A"))

    expect(user).not_to be_valid
    expect(user.errors[:matricula]).to include("deve conter apenas números")
  end

  it "não permite duas contas com a mesma matrícula" do
    User.create!(atributos)
    user = User.new(atributos.merge(nome: "Outra Pessoa"))

    expect(user).not_to be_valid
    expect(user.errors[:matricula]).to include("já possui uma conta cadastrada")
  end

  it "ignora espaços em volta da matrícula" do
    expect(User.new(atributos.merge(matricula: " 2023123456 ")).matricula).to eq("2023123456")
  end

  it "exige a senha" do
    user = User.new(atributos.merge(password: "", password_confirmation: ""))

    expect(user).not_to be_valid
    expect(user.errors[:password]).to include("não pode ficar em branco")
  end

  it "recusa senhas que não conferem" do
    user = User.new(atributos.merge(password_confirmation: "OutraSenha Diferente"))

    expect(user).not_to be_valid
    expect(user.errors[:password_confirmation]).to include("As senhas não conferem")
  end

  it "guarda a senha como foi digitada" do
    User.create!(atributos)

    expect(User.find_by(matricula: "2023123456").password).to eq("SenhaForte123")
  end
end
