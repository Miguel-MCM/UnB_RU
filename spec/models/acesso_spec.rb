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

  describe "entrada do FastPass" do
    let(:darcy) { Restaurante.create!(nome: "Darcy Ribeiro") }
    let(:gama) { Restaurante.create!(nome: "Gama") }
    let(:almoco) { darcy.turnos.create!(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00").tap { |turno| turno.dividir_em_time_frames!(15) } }
    let(:dia) { Date.new(2026, 11, 16) }
    let!(:inscricao) do
      travel_to(Time.zone.local(2026, 11, 16, 8, 0)) do
        InscricaoFastpass.inscrever!(user: estudante, time_frame: almoco.time_frames.first).tap(&:sorteado!)
      end
    end

    def ler_fastpass(hora, minuto, restaurante: darcy, identificacao: "100001")
      travel_to(Time.zone.local(dia.year, dia.month, dia.day, hora, minuto)) do
        Acesso.registrar_leitura!(identificacao, funcionario:, restaurante:, modalidade: "fastpass")
      end
    end

    it "libera o sorteado dentro do time-frame, inclusive nos limites, sem debitar" do
      [ [ 11, 0 ], [ 11, 5 ], [ 11, 15 ] ].each do |hora, minuto|
        acesso = ler_fastpass(hora, minuto)

        expect(acesso).to be_liberado
        expect(acesso).to be_modalidade_fastpass
        expect(acesso.inscricao_fastpass).to eq(inscricao)
      end
      expect(estudante.reload.saldo_centavos).to eq(1000)
    end

    it "bloqueia o sorteado antes ou depois do time-frame" do
      expect(ler_fastpass(10, 55)).to be_fora_do_time_frame
      expect(ler_fastpass(11, 20)).to be_fora_do_time_frame
    end

    it "bloqueia o estudante não sorteado" do
      inscricao.nao_sorteado!

      expect(ler_fastpass(11, 5)).to be_sem_fastpass
    end

    it "bloqueia o sorteado em outro restaurante" do
      expect(ler_fastpass(11, 5, restaurante: gama)).to be_sem_fastpass
    end

    it "bloqueia o FastPass já utilizado" do
      inscricao.utilizado!

      expect(ler_fastpass(11, 5)).to be_fastpass_utilizado
    end

    it "bloqueia o sorteado com saldo insuficiente" do
      estudante.update!(saldo_centavos: 599)

      expect(ler_fastpass(11, 5)).to be_saldo_insuficiente
    end

    it "nega uma identificação desconhecida" do
      expect(ler_fastpass(11, 5, identificacao: "999999")).to be_nao_encontrado
    end

    it "debita na confirmação, marca o FastPass como utilizado e não debita de novo" do
      primeiro = ler_fastpass(11, 5)
      segundo = ler_fastpass(11, 6)

      expect(primeiro.confirmar_passagem!).to be(true)
      expect(inscricao.reload).to be_utilizado
      expect(estudante.reload.saldo_centavos).to eq(400)

      expect(segundo.confirmar_passagem!).to be(false)
      expect(segundo.reload).to be_fastpass_utilizado
      expect(estudante.reload.saldo_centavos).to eq(400)
    end

    it "grava a inscrição encontrada também nas leituras bloqueadas" do
      expect(ler_fastpass(11, 20).inscricao_fastpass).to eq(inscricao)

      inscricao.utilizado!
      expect(ler_fastpass(11, 5).inscricao_fastpass).to eq(inscricao)
    end

    it "não debita na confirmação se a inscrição deixou de estar sorteada" do
      acesso = ler_fastpass(11, 5)
      inscricao.nao_sorteado!

      expect(acesso.confirmar_passagem!).to be(false)
      expect(acesso.reload).to be_sem_fastpass
      expect(estudante.reload.saldo_centavos).to eq(1000)
    end

    it "preserva o acesso ao excluir o restaurante, anulando a inscrição" do
      acesso = ler_fastpass(11, 5)

      expect { darcy.destroy! }.not_to raise_error
      expect(acesso.reload.inscricao_fastpass_id).to be_nil
    end

    it "preserva o acesso ao excluir o estudante, anulando a inscrição" do
      acesso = ler_fastpass(11, 5)

      expect { estudante.destroy! }.not_to raise_error
      expect(acesso.reload).to have_attributes(inscricao_fastpass_id: nil, user_id: nil)
    end

    it "mantém a entrada comum sem exigir FastPass" do
      acesso = travel_to(Time.zone.local(dia.year, dia.month, dia.day, 10, 55)) { ler("100001") }

      expect(acesso).to be_liberado
      expect(acesso).to be_modalidade_comum
      expect(acesso.inscricao_fastpass).to be_nil
    end
  end
end
