require "rails_helper"

RSpec.describe "Extrato e histórico", type: :request do
  let!(:estudante) do
    User.create!(nome: "Ana Beatriz Silva", matricula: "221045999", password: "Senha123", saldo_centavos: 1800)
  end
  let(:operador) { Funcionario.create!(nome: "Carlos Mendes", matricula: "1984201", password: "Operador123") }

  before do
    travel_to Time.zone.local(2024, 5, 20, 15, 0)

    Acesso.create!(user: estudante, funcionario: operador, identificacao: "221045999", status: "confirmado",
                   refeicao: "almoco", valor_centavos: 450, created_at: Time.zone.local(2024, 5, 14, 12, 20))
    Acesso.create!(user: estudante, funcionario: operador, identificacao: "221045999", status: "confirmado",
                   refeicao: "jantar", valor_centavos: 450, created_at: Time.zone.local(2024, 5, 13, 19, 10))
    Recarga.create!(user: estudante, quantidade: 10, metodo_pagamento: "pix", created_at: Time.zone.local(2024, 5, 10, 14, 0))
  end

  def entrar
    post login_path, params: { matricula: "221045999", password: "Senha123" }
  end

  it "exige que o estudante esteja autenticado" do
    get statements_path

    expect(response).to redirect_to(login_path)
  end

  describe "GET /extrato" do
    before { entrar }

    it "mostra os indicadores do mês" do
      get statements_path

      expect(response.body).to include("Total Gasto no Mês", "R$ 9,00", "2 débitos de R$ 4,50")
      expect(response.body).to include("Refeições Realizadas", "1 almoço · 1 jantar")
      expect(response.body).to include("Total Recarregado", "R$ 45,00", "Saldo restante: R$ 18,00")
    end

    it "lista os lançamentos com data, evento e valor" do
      get statements_path

      expect(response.body).to include("14/05/2024", "Almoço", "- R$ 4,50", "Recarga de Saldo", "+ R$ 45,00", "PIX Instantâneo")
    end

    it "aplica os filtros de período e tipo" do
      get statements_path(periodo: "30_dias", tipo: "jantar")

      expect(response.body).to include("13/05/2024")
      expect(response.body).not_to include("14/05/2024", "+ R$ 45,00")
    end

    it "avisa quando não há lançamentos para os filtros" do
      get statements_path(tipo: "cafe_da_manha")

      expect(response.body).to include("Nenhum lançamento encontrado")
    end
  end

  describe "GET /extrato/export_pdf" do
    before { entrar }

    it "baixa o extrato em PDF com os filtros aplicados" do
      get export_pdf_statements_path(periodo: "30_dias", tipo: "almoco")

      expect(response.media_type).to eq("application/pdf")
      expect(response.headers["Content-Disposition"]).to include("attachment", "extrato-221045999.pdf")

      texto = PDF::Reader.new(StringIO.new(response.body)).pages.map(&:text).join("\n")
      expect(texto).to include("Extrato e Histórico de Refeições", "Ana Beatriz Silva", "14/05/2024", "Almoço")
      expect(texto).not_to include("13/05/2024")
    end
  end
end
