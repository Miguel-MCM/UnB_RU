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
