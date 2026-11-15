require "rails_helper"

RSpec.describe Sorteio, type: :model do
  let(:almoco) { Restaurante.create!(nome: "Darcy Ribeiro").turnos.create!(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00") }

  describe ".do_dia!" do
    it "cria o sorteio do dia aberto para inscrições" do
      sorteio = Sorteio.do_dia!(almoco)

      expect(sorteio).to be_persisted
      expect(sorteio).to be_aberto
      expect(sorteio).to be_inscricoes_abertas
      expect(sorteio.data_refeicao).to eq(Date.current)
    end

    it "é idempotente para o mesmo turno e dia" do
      primeiro = Sorteio.do_dia!(almoco)

      expect(Sorteio.do_dia!(almoco)).to eq(primeiro)
      expect(Sorteio.count).to eq(1)
    end

    it "busca o sorteio criado por outra requisição quando perde a corrida" do
      existente = Sorteio.create!(turno: almoco, data_refeicao: Date.current)
      allow(Sorteio).to receive(:find_or_create_by!).and_raise(ActiveRecord::RecordInvalid.new(Sorteio.new))

      expect(Sorteio.do_dia!(almoco)).to eq(existente)
    end

    it "deixa o erro subir quando a falha não é de corrida" do
      allow(Sorteio).to receive(:find_or_create_by!).and_raise(ActiveRecord::RecordInvalid.new(Sorteio.new))

      expect { Sorteio.do_dia!(almoco) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "cria um sorteio por dia" do
      expect(Sorteio.do_dia!(almoco, Date.current + 1)).not_to eq(Sorteio.do_dia!(almoco))
    end
  end

  it "não repete o sorteio do mesmo turno no mesmo dia" do
    Sorteio.do_dia!(almoco)

    expect(Sorteio.new(turno: almoco, data_refeicao: Date.current)).not_to be_valid
  end

  it "encerra as inscrições" do
    sorteio = Sorteio.do_dia!(almoco)
    sorteio.encerrar!

    expect(sorteio.reload).to be_encerrado
    expect(sorteio).not_to be_inscricoes_abertas
  end

  describe ".notificar_pendentes!" do
    let(:dia) { Time.zone.local(2026, 11, 16, 8, 0) }
    let(:estudante) { User.create!(nome: "Mariana Souza Silva", matricula: "100001", password: "Senha123") }
    let(:inscricao) do
      almoco.dividir_em_time_frames!(15)
      travel_to(dia) { InscricaoFastpass.inscrever!(user: estudante, time_frame: almoco.time_frames.first) }
    end

    it "notifica 1 hora antes do início do turno" do
      inscricao.sorteado!

      Sorteio.notificar_pendentes!(dia.change(hour: 10))

      expect(estudante.notificacoes.sole).to be_contemplado
      expect(estudante.notificacoes.sole.inscricao_fastpass).to eq(inscricao)
    end

    it "não notifica antes de 1 hora do início do turno" do
      inscricao.sorteado!

      Sorteio.notificar_pendentes!(dia.change(hour: 9, min: 59))

      expect(Notificacao.count).to eq(0)
      expect(inscricao.sorteio.reload).to be_aberto
    end

    it "envia uma única notificação por inscrição" do
      inscricao.nao_sorteado!

      Sorteio.notificar_pendentes!(dia.change(hour: 10))
      Sorteio.notificar_pendentes!(dia.change(hour: 10, min: 30))

      expect(estudante.notificacoes.sole).to be_nao_contemplado
    end

    it "não notifica inscrições ainda sem resultado" do
      inscricao

      Sorteio.notificar_pendentes!(dia.change(hour: 10))

      expect(Notificacao.count).to eq(0)
      expect(inscricao.reload).to be_inscrito
    end

    it "realiza o sorteio e passa a recusar inscrições" do
      inscricao.sorteado!

      Sorteio.notificar_pendentes!(dia.change(hour: 10))

      expect(inscricao.sorteio.reload).to be_realizado
      outro = User.create!(nome: "João", matricula: "100002", password: "Senha123")
      tardia = travel_to(dia.change(hour: 10, min: 5)) { InscricaoFastpass.inscrever!(user: outro, time_frame: almoco.time_frames.last) }
      expect(tardia).not_to be_persisted
      expect(tardia.errors[:base]).to include("As inscrições para o turno estão encerradas")
    end

    it "cria o sorteio já realizado no turno sem inscrições" do
      almoco
      Sorteio.notificar_pendentes!(dia.change(hour: 10))

      expect(almoco.sorteios.sole).to be_realizado
      expect(almoco.sorteios.sole.data_refeicao).to eq(dia.to_date)
    end

    it "não toca os turnos cujo sorteio ainda não chegou" do
      jantar = almoco.restaurante.turnos.create!(nome: "jantar", hora_inicio: "17:00", hora_fim: "20:00")

      Sorteio.notificar_pendentes!(dia.change(hour: 10))

      expect(jantar.sorteios).to be_empty
    end

    it "não deixa um turno com erro impedir a notificação dos outros" do
      inscricao.sorteado!
      cafe = almoco.restaurante.turnos.create!(nome: "café da manhã", hora_inicio: "07:00", hora_fim: "09:00")
      erro = RuntimeError.new("falha no café")
      allow(Sorteio).to receive(:do_dia!).and_call_original
      allow(Sorteio).to receive(:do_dia!).with(cafe, dia.to_date).and_raise(erro)
      allow(Rails.error).to receive(:report)

      Sorteio.notificar_pendentes!(dia.change(hour: 10))

      expect(estudante.notificacoes.sole).to be_contemplado
      expect(Rails.error).to have_received(:report).with(erro, context: { turno_id: cafe.id, data_refeicao: dia.to_date })
    end

    it "só considera o sorteio do dia de agora" do
      inscricao.sorteado!

      Sorteio.notificar_pendentes!(dia.change(hour: 10) + 1.day)

      expect(Notificacao.count).to eq(0)
      expect(inscricao.sorteio.reload).to be_aberto
      expect(almoco.sorteios.find_by(data_refeicao: dia.to_date + 1)).to be_realizado
    end
  end
end
