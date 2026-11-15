require "rails_helper"

RSpec.describe LoginOperador, type: :model do
  let!(:funcionario) { Funcionario.create!(nome: "Carlos Mendes", matricula: "1984201", password: "Operador123") }

  it "marca matrícula e senha como campos obrigatórios" do
    login = LoginOperador.new(matricula: "", password: "")

    expect(login).not_to be_valid
    expect(login.errors[:matricula]).to eq([ "Campo obrigatório" ])
    expect(login.errors[:password]).to eq([ "Campo obrigatório" ])
  end

  it "devolve o funcionário com as credenciais certas" do
    expect(LoginOperador.new(matricula: "1984201", password: "Operador123").funcionario).to eq(funcionario)
  end

  it "não devolve funcionário com as credenciais erradas" do
    expect(LoginOperador.new(matricula: "1984201", password: "errada").funcionario).to be_nil
  end

  it "não consulta o banco quando faltam campos" do
    expect(Funcionario).not_to receive(:autenticar)

    expect(LoginOperador.new(matricula: "1984201", password: "").funcionario).to be_nil
  end
end
