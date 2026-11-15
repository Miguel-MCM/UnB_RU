require "rails_helper"

RSpec.describe Acesso, type: :model do
  let(:funcionario) { Funcionario.create!(nome: "Carlos Mendes", matricula: "1984201", password: "Operador123") }
  let!(:estudante) { User.create!(nome: "Mariana Souza Silva", matricula: "100001", password: "Senha123", saldo_centavos: 1000) }

  before { Tarifa.create!(valor_centavos: 600) }

  def ler(identificacao)
    Acesso.registrar_leitura!(identificacao, funcionario:)
  end

  describe ".registrar_leitura!" do
    it "libera a catraca sem debitar quando há saldo" do
      acesso = ler("100001")

      expect(acesso).to be_liberado
      expect(acesso.user).to eq(estudante)
      expect(acesso.valor_centavos).to eq(600)
      expect(estudante.reload.saldo_centavos).to eq(1000)
    end

    it "libera quando o saldo é igual à tarifa" do
      estudante.update!(saldo_centavos: 600)

      expect(ler("100001")).to be_liberado
    end

    it "nega por saldo insuficiente" do
      estudante.update!(saldo_centavos: 599)

      expect(ler("100001")).to be_saldo_insuficiente
    end

    it "nega uma identificação desconhecida e guarda o que foi lido" do
      acesso = ler(" 999999 ")

      expect(acesso).to be_nao_encontrado
      expect(acesso.user).to be_nil
      expect(acesso.identificacao).to eq("999999")
    end

    it "permite associar uma catraca opcional na leitura" do
      restaurante = Restaurante.create!(nome: "Darcy Ribeiro")
      catraca = restaurante.catracas.create!(nome: "Entrada 1")
      acesso = Acesso.registrar_leitura!("100001", funcionario:, catraca:)

      expect(acesso.catraca).to eq(catraca)
    end

    it "grava o restaurante do ponto de acesso" do
      restaurante = Restaurante.create!(nome: "Darcy Ribeiro")
      acesso = Acesso.registrar_leitura!("100001", funcionario:, restaurante:)

      expect(acesso.restaurante).to eq(restaurante)
    end
  end

  describe "coerência entre catraca e restaurante" do
    let(:darcy) { Restaurante.create!(nome: "Darcy Ribeiro") }
    let(:gama) { Restaurante.create!(nome: "Gama") }
    let(:catraca) { darcy.catracas.create!(nome: "Entrada 1") }

    def acesso(**atributos)
      Acesso.new(identificacao: "100001", funcionario:, valor_centavos: 600, status: :liberado, **atributos)
    end

    it "aceita a catraca do mesmo restaurante" do
      expect(acesso(catraca:, restaurante: darcy)).to be_valid
    end

    it "assume o restaurante da catraca quando ele não é informado" do
      registro = acesso(catraca:)

      expect(registro).to be_valid
      expect(registro.restaurante).to eq(darcy)
    end

    it "rejeita uma catraca de outro restaurante" do
      registro = acesso(catraca:, restaurante: gama)

      expect(registro).not_to be_valid
      expect(registro.errors[:catraca]).to include("não pertence ao restaurante do ponto de acesso")
    end
  end

  describe ".refeicao_do_horario" do
    it "classifica a leitura pelo turno do dia" do
      expect(Acesso.refeicao_do_horario(Time.zone.local(2024, 5, 14, 7, 45))).to eq("cafe_da_manha")
      expect(Acesso.refeicao_do_horario(Time.zone.local(2024, 5, 14, 12, 20))).to eq("almoco")
      expect(Acesso.refeicao_do_horario(Time.zone.local(2024, 5, 14, 19, 10))).to eq("jantar")
    end
  end

  it "registra a refeição do horário da leitura" do
    travel_to Time.zone.local(2024, 5, 14, 12, 20) do
      expect(ler("100001").refeicao).to eq("almoco")
    end
  end

  describe "#confirmar_passagem!" do
    it "debita a tarifa do momento da leitura" do
      acesso = ler("100001")
      Tarifa.create!(valor_centavos: 800)

      expect(acesso.confirmar_passagem!).to be(true)

      expect(acesso.reload).to be_confirmado
      expect(estudante.reload.saldo_centavos).to eq(400)
    end

    it "não debita duas vezes a mesma passagem" do
      acesso = ler("100001")
      acesso.confirmar_passagem!

      expect(acesso.confirmar_passagem!).to be(false)
      expect(estudante.reload.saldo_centavos).to eq(400)
    end

    it "não debita uma leitura negada" do
      estudante.update!(saldo_centavos: 599)
      acesso = ler("100001")

      expect(acesso.confirmar_passagem!).to be(false)
      expect(estudante.reload.saldo_centavos).to eq(599)
    end

    it "não deixa o saldo negativo se ele caiu entre a leitura e a passagem" do
      acesso = ler("100001")
      estudante.update!(saldo_centavos: 100)

      expect(acesso.confirmar_passagem!).to be(false)
      expect(acesso.reload).to be_saldo_insuficiente
      expect(estudante.reload.saldo_centavos).to eq(100)
    end
  end
end
