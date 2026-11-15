require "rails_helper"

RSpec.describe "Relatório Global de Acessos", type: :request do
  let!(:admin) do
    Funcionario.create!(
      nome: "Admin RU",
      matricula: "100200300",
      password: "Password123",
      administrador: true
    )
  end

  let!(:operador_comum) do
    Funcionario.create!(
      nome: "Operador Catraca",
      matricula: "100200301",
      password: "Password123",
      administrador: false
    )
  end

  let!(:darcy) { Restaurante.create!(nome: "Darcy Ribeiro") }
  let!(:gama) { Restaurante.create!(nome: "Gama") }
  let!(:entrada1) { Catraca.create!(nome: "Entrada 1", restaurante: darcy) }
  let!(:entrada2) { Catraca.create!(nome: "Entrada 2", restaurante: darcy) }
  let!(:catraca_gama) { Catraca.create!(nome: "Catraca Gama", restaurante: gama) }

  def login_como_operador(funcionario)
    credenciais = { matricula: funcionario.matricula, password: "Password123" }
    post operador_login_path, params: credenciais.merge(
      login_operador: credenciais,
      funcionario: credenciais,
      operador: credenciais
    )
  end

  before do
    login_como_operador(admin)
    Acesso.create!(funcionario: admin, restaurante: darcy, catraca: entrada1, identificacao: "231012345", status: :confirmado, valor_centavos: 450)
    Acesso.create!(funcionario: admin, restaurante: gama, catraca: catraca_gama, identificacao: "231099999", status: :confirmado, valor_centavos: 450)
  end

  it "exibe os acessos de todos os restaurantes sem filtro (caminho feliz)" do
    get access_reports_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Darcy Ribeiro", "Gama")
  end

  it "filtra os acessos por restaurante (caminho feliz)" do
    get access_reports_path, params: { restaurante_nome: "Darcy Ribeiro" }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Entrada 1")
    expect(response.body).not_to include("Catraca Gama")
  end

  it "filtra os acessos por catraca específica (caminho feliz)" do
    Acesso.create!(funcionario: admin, restaurante: darcy, catraca: entrada2, identificacao: "231088888", status: :confirmado, valor_centavos: 450)
    get access_reports_path, params: { catraca_nome: "Entrada 1" }
    expect(response.body).to include("Entrada 1")
    expect(response.body).not_to include("Entrada 2")
  end

  it "agrupa o total de acessos por restaurante e por catraca (caminho feliz)" do
    get access_reports_path, params: { group_by: "restaurante" }
    expect(response.body).to include("Darcy Ribeiro: 1 acessos", "Gama: 1 acessos")

    get access_reports_path, params: { group_by: "catraca" }
    expect(response.body).to include("Entrada 1: 1 acessos", "Catraca Gama: 1 acessos")
  end

  it "informa quando o restaurante filtrado não possui acessos (caminho triste)" do
    Restaurante.create!(nome: "Planaltina")
    get access_reports_path, params: { restaurante_nome: "Planaltina" }
    expect(response.body).to include("Não há acessos para o filtro selecionado")
  end

  it "informa erro quando a catraca não pertence ao restaurante selecionado (caminho triste)" do
    get access_reports_path, params: { restaurante_nome: "Gama", catraca_nome: "Entrada 1" }
    expect(response.body).to include("A catraca Entrada 1 não pertence ao restaurante Gama")
  end

  it "bloqueia funcionário que não é administrador (caminho triste)" do
    login_como_operador(operador_comum)
    get access_reports_path
    expect(response).to redirect_to(operador_terminal_path)
  end
end
