require "rails_helper"

RSpec.describe "Inscrições no FastPass", type: :request do
  let!(:estudante) { User.create!(nome: "Ana Beatriz Silva", matricula: "221045999", password: "Senha123") }
  let(:almoco) do
    Restaurante.create!(nome: "Darcy Ribeiro").turnos
      .create!(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00").tap { |turno| turno.dividir_em_time_frames!(15) }
  end
  let(:primeiro) { almoco.time_frames.first }

  def entrar
    post login_path, params: { matricula: "221045999", password: "Senha123" }
  end

  it "exige que o estudante esteja autenticado" do
    expect { post inscricoes_fastpass_path, params: { time_frame_id: primeiro.id } }.not_to change(InscricaoFastpass, :count)
    expect(response).to redirect_to(login_path)
  end

  it "inscreve o estudante e redireciona com aviso" do
    entrar

    expect { post inscricoes_fastpass_path, params: { time_frame_id: primeiro.id } }.to change(InscricaoFastpass, :count).by(1)
    expect(response).to redirect_to(fastpass_path)
    expect(flash[:notice]).to eq("Inscrição realizada no time-frame das 11:00 às 11:15 do almoço.")
    expect(estudante.inscricoes_fastpass.sole.time_frame).to eq(primeiro)
  end

  it "recusa um segundo time-frame no mesmo turno com alerta" do
    entrar
    post inscricoes_fastpass_path, params: { time_frame_id: primeiro.id }

    expect { post inscricoes_fastpass_path, params: { time_frame_id: almoco.time_frames.last.id } }.not_to change(InscricaoFastpass, :count)
    expect(response).to redirect_to(fastpass_path)
    expect(flash[:alert]).to eq("Só é permitido um time-frame por turno")
  end

  it "recusa com as inscrições encerradas" do
    entrar
    Sorteio.do_dia!(almoco).encerrar!

    post inscricoes_fastpass_path, params: { time_frame_id: primeiro.id }

    expect(flash[:alert]).to eq("As inscrições para o turno estão encerradas")
    expect(InscricaoFastpass.count).to eq(0)
  end
end
