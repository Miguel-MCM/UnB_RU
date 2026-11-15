require "rails_helper"
require "pdf-reader"

RSpec.describe "Exportação em PDF do Histórico do Estudante (Issue #16)", type: :request do
  let!(:estudante) do
    User.create!(
      nome: "João Pedro Borges",
      matricula: "231012345",
      password: "Password123",
      saldo_centavos: 1800
    )
  end

  let!(:outro_estudante) do
    User.create!(
      nome: "Outro Estudante",
      matricula: "222098765",
      password: "Password123",
      saldo_centavos: 900
    )
  end

  let!(:operador) do
    Funcionario.create!(
      nome: "Operador RU",
      matricula: "999111222",
      password: "Password123",
      administrador: false
    )
  end

  before do
    post login_path, params: { matricula: estudante.matricula, password: "Password123" }
  end

  it "exporta o extrato contendo as recargas, refeições e os totais do período (caminho feliz)" do
    estudante.recargas.create!(quantidade: 5, metodo_pagamento: "pix")
    Acesso.create!(
      user: estudante,
      funcionario: operador,
      identificacao: estudante.matricula,
      status: :confirmado,
      valor_centavos: 450,
      refeicao: "almoco"
    )

    get export_pdf_statements_path
    expect(response).to have_http_status(:ok)
    expect(response.content_type).to eq("application/pdf")

    texto = PDF::Reader.new(StringIO.new(response.body.b)).pages.map(&:text).join("\n")
    expect(texto).to include("Recarga de Saldo", "Almoço")
    expect(texto).to include("Total gasto no mês: R$ 4,50", "Total recarregado no mês: R$ 22,50", "Saldo restante: R$ 18,00")
  end

  it "respeita os filtros de período e tipo de refeição na exportação (caminho feliz)" do
    Acesso.create!(
      user: estudante,
      funcionario: operador,
      identificacao: estudante.matricula,
      status: :confirmado,
      valor_centavos: 450,
      refeicao: "almoco"
    )
    Acesso.create!(
      user: estudante,
      funcionario: operador,
      identificacao: estudante.matricula,
      status: :confirmado,
      valor_centavos: 450,
      refeicao: "jantar"
    )

    get export_pdf_statements_path, params: { periodo: "mes_atual", tipo: "almoco" }
    expect(response).to have_http_status(:ok)

    texto = PDF::Reader.new(StringIO.new(response.body.b)).pages.map(&:text).join("\n")
    expect(texto).to include("Almoço")
    expect(texto).not_to include("Jantar")
  end

  it "inclui apenas os registros do próprio estudante autenticado (caminho feliz)" do
    estudante.recargas.create!(quantidade: 2, metodo_pagamento: "pix")
    Acesso.create!(user: outro_estudante, funcionario: operador, identificacao: outro_estudante.matricula, status: :confirmado, valor_centavos: 450)

    get export_pdf_statements_path
    texto = PDF::Reader.new(StringIO.new(response.body.b)).pages.map(&:text).join("\n")
    expect(texto).to include("231012345")
    expect(texto).not_to include("222098765")
  end

  it "não gera PDF e exibe alerta quando não há registros para exportar (caminho triste)" do
    get export_pdf_statements_path
    expect(response).to redirect_to(statements_path)
    follow_redirect!
    expect(response.body).to include("Não há registros para exportar")
  end

  it "redireciona para login quando o estudante não está autenticado (caminho triste)" do
    delete logout_path
    get export_pdf_statements_path
    expect(response).to redirect_to(login_path)
  end
end
