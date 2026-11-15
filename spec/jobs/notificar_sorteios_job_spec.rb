require "rails_helper"

RSpec.describe NotificarSorteiosJob, type: :job do
  let(:almoco) do
    Restaurante.create!(nome: "Darcy Ribeiro").turnos
      .create!(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00").tap { |turno| turno.dividir_em_time_frames!(15) }
  end
  let(:estudante) { User.create!(nome: "Mariana Souza Silva", matricula: "100001", password: "Senha123") }
  let(:dia) { Time.zone.local(2026, 11, 16, 8, 0) }
  let!(:inscricao) do
    travel_to(dia) { InscricaoFastpass.inscrever!(user: estudante, time_frame: almoco.time_frames.first) }.tap(&:sorteado!)
  end

  it "notifica os sorteios que chegaram a 1 hora do turno" do
    travel_to(dia.change(hour: 10)) { described_class.perform_now }

    expect(estudante.notificacoes.sole).to be_contemplado
  end

  it "não notifica antes da hora" do
    travel_to(dia.change(hour: 9, min: 59)) { described_class.perform_now }

    expect(Notificacao.count).to eq(0)
  end
end
