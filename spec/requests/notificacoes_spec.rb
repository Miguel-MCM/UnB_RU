require "rails_helper"

RSpec.describe "Notificações", type: :request do
  let!(:estudante) { User.create!(nome: "Ana Beatriz Silva", matricula: "221045999", password: "Senha123") }
  let(:almoco) do
    Restaurante.create!(nome: "Darcy Ribeiro").turnos
      .create!(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00").tap { |turno| turno.dividir_em_time_frames!(15) }
  end

  def entrar
    post login_path, params: { matricula: "221045999", password: "Senha123" }
  end

  def notificar(user, status)
    inscricao = InscricaoFastpass.inscrever!(user:, time_frame: almoco.time_frames.first)
    inscricao.public_send(status)
    inscricao.notificar!
  end

  it "exige que o estudante esteja autenticado" do
    get notificacoes_path

    expect(response).to redirect_to(login_path)
  end

  it "mostra apenas as notificações do estudante" do
    notificar(estudante, :sorteado!)
    notificar(User.create!(nome: "Outro", matricula: "100002", password: "Senha123"), :nao_sorteado!)
    entrar

    get notificacoes_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("notificacao--contemplado", "Você ganhou o FastPass do almoço", "das 11:00 às 11:15")
    expect(response.body).not_to include("Você não ganhou")
  end

  it "avisa quando não há notificações" do
    entrar

    get notificacoes_path

    expect(response.body).to include("Você não tem notificações.")
  end
end
