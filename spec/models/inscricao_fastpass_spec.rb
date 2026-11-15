require "rails_helper"

RSpec.describe InscricaoFastpass, type: :model do
  let(:darcy) { Restaurante.create!(nome: "Darcy Ribeiro") }
  let(:almoco) { darcy.turnos.create!(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00").tap { |turno| turno.dividir_em_time_frames!(15) } }
  let(:jantar) { darcy.turnos.create!(nome: "jantar", hora_inicio: "17:00", hora_fim: "20:00").tap { |turno| turno.dividir_em_time_frames!(15) } }
  let(:estudante) { User.create!(nome: "Mariana Souza Silva", matricula: "100001", password: "Senha123", saldo_centavos: 1000) }

  def inscrever(time_frame)
    InscricaoFastpass.inscrever!(user: estudante, time_frame:)
  end

  it "inscreve o estudante no sorteio do dia do turno do time-frame" do
    inscricao = inscrever(almoco.time_frames.first)

    expect(inscricao).to be_persisted
    expect(inscricao).to be_inscrito
    expect(inscricao.sorteio).to eq(Sorteio.do_dia!(almoco))
    expect(estudante.inscricoes_fastpass.do_dia.do_turno(almoco)).to eq([ inscricao ])
  end

  it "recusa um segundo time-frame no mesmo turno" do
    inscrever(almoco.time_frames.first)
    segunda = inscrever(almoco.time_frames.last)

    expect(segunda).not_to be_persisted
    expect(segunda.errors[:base]).to include("Só é permitido um time-frame por turno")
    expect(estudante.inscricoes_fastpass.count).to eq(1)
  end

  it "permite inscrições em turnos diferentes" do
    inscrever(almoco.time_frames.first)

    expect(inscrever(jantar.time_frames.first)).to be_persisted
    expect(estudante.inscricoes_fastpass.count).to eq(2)
  end

  it "recusa a inscrição com as inscrições encerradas" do
    Sorteio.do_dia!(almoco).encerrar!
    inscricao = inscrever(almoco.time_frames.first)

    expect(inscricao).not_to be_persisted
    expect(inscricao.errors[:base]).to include("As inscrições para o turno estão encerradas")
  end

  it "não cobra pela inscrição" do
    expect { inscrever(almoco.time_frames.first) }.not_to(change { estudante.reload.saldo_centavos })
  end

  it "recusa um time-frame de outro turno" do
    inscricao = InscricaoFastpass.new(user: estudante, sorteio: Sorteio.do_dia!(almoco), time_frame: jantar.time_frames.first)

    expect(inscricao).not_to be_valid
    expect(inscricao.errors[:base]).to include("O time-frame não pertence ao turno do sorteio")
  end

  describe "contempladas" do
    let(:gama) { Restaurante.create!(nome: "Gama") }
    let(:momento) { Time.zone.local(2026, 11, 16, 11, 5) }
    let(:inscricao) do
      travel_to(momento.change(hour: 8)) { inscrever(almoco.time_frames.first) }
    end

    it "considera contempladas as inscrições sorteadas ou utilizadas" do
      inscricao.sorteado!
      expect(InscricaoFastpass.contempladas).to eq([ inscricao ])

      inscricao.utilizado!
      expect(InscricaoFastpass.contempladas).to eq([ inscricao ])

      inscricao.nao_sorteado!
      expect(InscricaoFastpass.contempladas).to be_empty
    end

    it "filtra as inscrições do restaurante" do
      expect(InscricaoFastpass.do_restaurante(darcy)).to eq([ inscricao ])
      expect(InscricaoFastpass.do_restaurante(gama)).to be_empty
    end

    describe ".contemplada_de" do
      before { inscricao.sorteado! }

      it "encontra a inscrição sorteada do estudante no restaurante e no dia" do
        expect(InscricaoFastpass.contemplada_de(estudante, darcy, momento)).to eq(inscricao)
      end

      it "encontra a inscrição mesmo fora do time-frame, para identificar o atraso" do
        expect(InscricaoFastpass.contemplada_de(estudante, darcy, momento.change(hour: 10, min: 55))).to eq(inscricao)
        expect(InscricaoFastpass.contemplada_de(estudante, darcy, momento.change(min: 20))).to eq(inscricao)
      end

      it "prefere a inscrição do turno que cobre o momento" do
        do_jantar = travel_to(momento.change(hour: 8)) { inscrever(jantar.time_frames.last) }.tap(&:sorteado!)

        expect(InscricaoFastpass.contemplada_de(estudante, darcy, momento.change(hour: 18))).to eq(do_jantar)
        expect(InscricaoFastpass.contemplada_de(estudante, darcy, momento.change(hour: 12))).to eq(inscricao)
      end

      it "ignora inscrições não sorteadas, de outro restaurante ou de outro dia" do
        expect(InscricaoFastpass.contemplada_de(estudante, gama, momento)).to be_nil
        expect(InscricaoFastpass.contemplada_de(estudante, darcy, momento + 1.day)).to be_nil

        inscricao.nao_sorteado!
        expect(InscricaoFastpass.contemplada_de(estudante, darcy, momento)).to be_nil
      end
    end
  end
end
