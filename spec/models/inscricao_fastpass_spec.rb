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
end
