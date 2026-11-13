require "rails_helper"

RSpec.describe "Divisão de turnos em time-frames", type: :request do
  let!(:administrador) do
    Funcionario.create!(nome: "Fernando Albuquerque", matricula: "1083921", password: "Admin123", administrador: true)
  end
  let!(:operador) { Funcionario.create!(nome: "Carlos Mendes", matricula: "1984201", password: "Operador123") }
  let!(:darcy) { Restaurante.create!(nome: "Darcy Ribeiro") }
  let!(:almoco) { darcy.turnos.create!(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00") }

  def entrar(funcionario, password)
    post operador_login_path, params: { login_operador: { matricula: funcionario.matricula, password: } }
  end

  def dividir(minutos)
    post admin_turno_time_frames_path(almoco), params: { duracao_time_frame_min: minutos }
  end

  it "exige um funcionário autenticado" do
    expect { dividir(15) }.not_to change(TimeFrame, :count)
    expect(response).to redirect_to(operador_login_path)
  end

  it "não deixa um operador comum dividir turnos" do
    entrar(operador, "Operador123")

    expect { dividir(15) }.not_to change(TimeFrame, :count)
    expect(response).to redirect_to(operador_terminal_path)
  end

  context "com o administrador autenticado" do
    before { entrar(administrador, "Admin123") }

    it "divide o turno em time-frames" do
      expect { dividir(15) }.to change { almoco.time_frames.count }.from(0).to(12)

      expect(response).to redirect_to(admin_restaurante_turnos_path(darcy))
      follow_redirect!
      expect(response.body).to include("Time-frames atualizados")
    end

    it "avisa e não altera nada com uma duração maior que o turno" do
      dividir(15)

      expect { dividir(240) }.not_to change { almoco.time_frames.count }
      expect(almoco.reload.duracao_time_frame_min).to eq(15)
      follow_redirect!
      expect(response.body).to include("A duração do time-frame não pode ser maior que a duração do turno")
    end
  end
end
