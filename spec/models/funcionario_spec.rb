require "rails_helper"

RSpec.describe Funcionario, type: :model do
  let(:atributos) { { nome: "Carlos Mendes", matricula: "1984201", password: "Operador123" } }

  it "é válido com nome, matrícula e senha" do
    expect(Funcionario.new(atributos)).to be_valid
  end

  it "aceita o usuário SIGAA / gov.br no lugar da matrícula SIAPE" do
    expect(Funcionario.new(atributos.merge(matricula: "operador.darcy"))).to be_valid
  end

  it "exige nome, matrícula e senha" do
    funcionario = Funcionario.new

    expect(funcionario).not_to be_valid
    expect(funcionario.errors.attribute_names).to include(:nome, :matricula, :password)
  end

  it "não é administrador a menos que isso seja definido" do
    expect(Funcionario.new(atributos)).not_to be_administrador
    expect(Funcionario.new(atributos.merge(administrador: true))).to be_administrador
  end

  it "não permite duas contas com a mesma matrícula" do
    Funcionario.create!(atributos)

    expect(Funcionario.new(atributos)).not_to be_valid
  end

  describe ".autenticar" do
    let!(:funcionario) { Funcionario.create!(atributos) }

    it "devolve o funcionário quando matrícula e senha conferem" do
      expect(Funcionario.autenticar("1984201", "Operador123")).to eq(funcionario)
    end

    it "devolve nil com a senha errada" do
      expect(Funcionario.autenticar("1984201", "errada")).to be_nil
    end

    it "devolve nil com uma matrícula que não existe" do
      expect(Funcionario.autenticar("0000000", "Operador123")).to be_nil
    end

    it "devolve nil sem matrícula ou sem senha" do
      expect(Funcionario.autenticar(nil, "Operador123")).to be_nil
      expect(Funcionario.autenticar("1984201", nil)).to be_nil
    end
  end

  it "não pode ser removido enquanto tiver leituras registradas" do
    funcionario = Funcionario.create!(atributos)
    Acesso.create!(funcionario:, identificacao: "100001", status: :nao_encontrado, valor_centavos: 450)

    expect(funcionario.destroy).to be(false)
    expect(funcionario.errors).not_to be_empty
  end
end
