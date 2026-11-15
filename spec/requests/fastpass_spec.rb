require "rails_helper"

RSpec.describe "FastPass", type: :request do
  let!(:estudante) { User.create!(nome: "Ana Beatriz Silva", matricula: "221045999", password: "Senha123") }
  let!(:almoco) do
    Restaurante.create!(nome: "Darcy Ribeiro").turnos
      .create!(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00").tap { |turno| turno.dividir_em_time_frames!(15) }
  end

  it "exige que o estudante esteja autenticado" do
    get fastpass_path

    expect(response).to redirect_to(login_path)
  end

  it "mostra os time-frames dos turnos com o botão de inscrição" do
    post login_path, params: { matricula: "221045999", password: "Senha123" }

    get fastpass_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("FastPass", "Darcy Ribeiro", "almoço", "11:00 às 11:15", "13:45 às 14:00", "Inscrever-se")
    expect(response.body).not_to include("Você está participando do sorteio")
  end

  it "marca o time-frame em que o estudante está inscrito" do
    InscricaoFastpass.inscrever!(user: estudante, time_frame: almoco.time_frames.first)
    post login_path, params: { matricula: "221045999", password: "Senha123" }

    get fastpass_path

    expect(response.body).to include("Inscrito", "Você está participando do sorteio do FastPass deste turno.")
  end
end
