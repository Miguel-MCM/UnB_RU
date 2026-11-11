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
  end
end
