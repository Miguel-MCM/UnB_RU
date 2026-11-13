require "rails_helper"

RSpec.describe "FastPass", type: :request do
  before do
    User.create!(nome: "Ana Beatriz Silva", matricula: "221045999", password: "Senha123")
    Restaurante.create!(nome: "Darcy Ribeiro").turnos
      .create!(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00").dividir_em_time_frames!(15)
  end

  it "exige que o estudante esteja autenticado" do
    get fastpass_path

    expect(response).to redirect_to(login_path)
  end

  it "mostra os time-frames dos turnos para o estudante autenticado" do
    post login_path, params: { matricula: "221045999", password: "Senha123" }

    get fastpass_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("FastPass", "Darcy Ribeiro", "almoço", "11:00 às 11:15", "13:45 às 14:00")
  end
end
