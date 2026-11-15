require "rails_helper"
require "pdf-reader"

RSpec.describe "Exportação em PDF do Relatório de Operação (Issue #17)", type: :request do
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
  end

  it "gera um arquivo PDF contendo os acessos de todos os restaurantes (caminho feliz)" do
    Acesso.create!(funcionario: admin, restaurante: darcy, catraca: entrada1, identificacao: "231012345", status: :confirmado, valor_centavos: 450)
    Acesso.create!(funcionario: admin, restaurante: gama, catraca: catraca_gama, identificacao: "231099999", status: :confirmado, valor_centavos: 450)

    get export_pdf_access_reports_path
    expect(response).to have_http_status(:ok)
    expect(response.content_type).to eq("application/pdf")

    texto = PDF::Reader.new(StringIO.new(response.body.b)).pages.map(&:text).join("\n")
    expect(texto).to include("Darcy Ribeiro", "Gama", "231012345", "231099999")
  end

  it "exporta em PDF apenas os acessos do restaurante filtrado (caminho feliz)" do
    Acesso.create!(funcionario: admin, restaurante: darcy, catraca: entrada1, identificacao: "231012345", status: :confirmado, valor_centavos: 450)
    Acesso.create!(funcionario: admin, restaurante: gama, catraca: catraca_gama, identificacao: "231099999", status: :confirmado, valor_centavos: 450)

    get export_pdf_access_reports_path, params: { restaurante_nome: "Darcy Ribeiro" }
    expect(response).to have_http_status(:ok)
    expect(response.content_type).to eq("application/pdf")

    texto = PDF::Reader.new(StringIO.new(response.body.b)).pages.map(&:text).join("\n")
    expect(texto).to include("Darcy Ribeiro", "Entrada 1")
    expect(texto).not_to include("Catraca Gama")
  end

  it "não gera arquivo PDF e informa quando não existem acessos registrados (caminho triste)" do
    Acesso.delete_all

    get export_pdf_access_reports_path
    expect(response).to redirect_to(access_reports_path)
    follow_redirect!
    expect(response.body).to include("Não há dados para exportar")
  end

  it "bloqueia a exportação por funcionário sem perfil de administrador (caminho triste)" do
    login_como_operador(operador_comum)
    get export_pdf_access_reports_path
    expect(response).to redirect_to(operador_terminal_path)
  end
end
