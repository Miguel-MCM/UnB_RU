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

  it "começa com saldo zero" do
    user = User.create!(atributos)

    expect(user.saldo_centavos).to eq(0)
    expect(user.refeicoes_disponiveis).to eq(0)
  end

  it "converte o saldo em refeições pela tarifa única de R$ 4,50" do
    expect(User.new(saldo_centavos: 1800).refeicoes_disponiveis).to eq(4)
    expect(User.new(saldo_centavos: 1000).refeicoes_disponiveis).to eq(2)
  end

  describe ".autenticar" do
    let!(:user) { User.create!(atributos) }

    it "devolve o usuário quando matrícula e senha conferem" do
      expect(User.autenticar(" 2023123456 ", "SenhaForte123")).to eq(user)
    end

    it "devolve nil com a senha errada" do
      expect(User.autenticar("2023123456", "errada")).to be_nil
    end

    it "devolve nil com uma matrícula que não existe" do
      expect(User.autenticar("999", "SenhaForte123")).to be_nil
    end
  end

  describe "#recarregar!" do
    let(:user) { User.create!(atributos.merge(saldo_centavos: 1800)) }

    it "registra a recarga e soma o valor ao saldo" do
      recarga = user.recarregar!(quantidade: 5, metodo_pagamento: "pix")

      expect(recarga).to be_persisted
      expect(recarga.valor_centavos).to eq(2250)
      expect(user.reload.saldo_centavos).to eq(4050)
    end

    it "não altera o saldo quando a recarga é inválida" do
      expect { user.recarregar!(quantidade: 0, metodo_pagamento: "pix") }.to raise_error(ActiveRecord::RecordInvalid)

      expect(user.reload.saldo_centavos).to eq(1800)
      expect(user.recargas).to be_empty
    end
  end
end
