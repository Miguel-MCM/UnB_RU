require "rails_helper"

RSpec.describe Extrato do
  let(:agora) { Time.zone.local(2024, 5, 20, 15, 0) }
  let(:estudante) { User.create!(nome: "Ana Beatriz Silva", matricula: "221045999", password: "Senha123", saldo_centavos: 1800) }
  let(:operador) { Funcionario.create!(nome: "Carlos Mendes", matricula: "1984201", password: "Operador123") }

  def refeicao!(refeicao, em:, status: "confirmado", user: estudante)
    Acesso.create!(user:, funcionario: operador, identificacao: user.matricula, status:, refeicao:,
                   valor_centavos: 450, created_at: em)
  end

  def recarga!(quantidade, em:, user: estudante)
    Recarga.create!(user:, quantidade:, metodo_pagamento: "pix", created_at: em)
  end

  def extrato(**filtros)
    Extrato.new(estudante, agora:, **filtros)
  end

  before do
    refeicao!("almoco", em: Time.zone.local(2024, 5, 10, 12, 20))
    refeicao!("jantar", em: Time.zone.local(2024, 5, 12, 19, 10))
    refeicao!("almoco", em: Time.zone.local(2024, 4, 25, 12, 40))
    refeicao!("almoco", em: Time.zone.local(2024, 5, 13, 12, 0), status: "liberado")
    recarga!(10, em: Time.zone.local(2024, 5, 5, 9, 0))
    recarga!(4, em: Time.zone.local(2024, 4, 2, 9, 0))
  end

  describe "indicadores do mês" do
    it "soma o que foi gasto só com passagens confirmadas no mês" do
      expect(extrato.total_gasto_no_mes).to eq(900)
      expect(extrato.debitos_no_mes).to eq(2)
    end

    it "conta as refeições do mês por tipo" do
      expect(extrato.refeicoes_no_mes).to eq("almoco" => 1, "jantar" => 1)
    end

    it "soma o que foi recarregado no mês" do
      expect(extrato.total_recarregado_no_mes).to eq(4500)
      expect(extrato.recargas_no_mes).to eq(1)
    end

    it "não mistura os registros de outro estudante" do
      outro = User.create!(nome: "Outro", matricula: "100002", password: "Senha123")
      refeicao!("almoco", em: Time.zone.local(2024, 5, 11, 12, 0), user: outro)

      expect(extrato.debitos_no_mes).to eq(2)
    end
  end

  describe "#lancamentos" do
    it "lista refeições e recargas do mês atual, das mais recentes para as mais antigas" do
      eventos = extrato.lancamentos.map(&:evento)

      expect(eventos).to eq(%w[jantar almoco recarga])
    end

    it "mostra débitos como valores negativos e recargas como positivos" do
      expect(extrato.lancamentos.map(&:valor_centavos)).to eq([ -450, -450, 4500 ])
    end

    it "filtra os últimos 30 dias" do
      expect(extrato(periodo: "30_dias").lancamentos.size).to eq(4)
    end

    it "filtra pelo tipo de refeição" do
      lancamentos = extrato(periodo: "30_dias", tipo: "almoco").lancamentos

      expect(lancamentos.map(&:momento)).to eq([ Time.zone.local(2024, 5, 10, 12, 20), Time.zone.local(2024, 4, 25, 12, 40) ])
    end

    it "filtra só as recargas" do
      expect(extrato(periodo: "tudo", tipo: "recarga").lancamentos.map(&:evento)).to eq(%w[recarga recarga])
    end

    it "ignora filtros desconhecidos" do
      expect(extrato(periodo: "x", tipo: "y").lancamentos.size).to eq(3)
    end
  end

  it "nomeia o período com o mês atual" do
    expect(Extrato.opcoes_de_periodo(agora)).to include([ "Últimos 30 dias (Maio/2024)", "30_dias" ])
  end
end
