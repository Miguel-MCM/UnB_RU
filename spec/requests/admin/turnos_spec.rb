require "rails_helper"

RSpec.describe "Gestão de turnos", type: :request do
  let!(:administrador) do
    Funcionario.create!(nome: "Fernando Albuquerque", matricula: "1083921", password: "Admin123", administrador: true)
  end
  let!(:operador) { Funcionario.create!(nome: "Carlos Mendes", matricula: "1984201", password: "Operador123") }
  let!(:darcy) { Restaurante.create!(nome: "Darcy Ribeiro") }
  let(:parametros) { { turno: { nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00" } } }

  def entrar(funcionario, password)
    post operador_login_path, params: { login_operador: { matricula: funcionario.matricula, password: } }
  end

  describe "acesso" do
    it "exige um funcionário autenticado" do
      get admin_restaurante_turnos_path(darcy)

      expect(response).to redirect_to(operador_login_path)
    end

    it "não deixa um operador comum cadastrar turnos" do
      entrar(operador, "Operador123")

      expect { post admin_restaurante_turnos_path(darcy), params: parametros }.not_to change(Turno, :count)
      expect(response).to redirect_to(operador_terminal_path)
    end
  end

  context "com o administrador autenticado" do
    before { entrar(administrador, "Admin123") }

    it "lista os turnos do restaurante com os time-frames" do
      darcy.turnos.create!(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00").dividir_em_time_frames!(15)

      get admin_restaurante_turnos_path(darcy)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Turnos — Darcy Ribeiro", "almoço", "11:00 às 14:00", "11:00 às 11:15", "12 time-frames")
    end

    it "cadastra um turno" do
      expect { post admin_restaurante_turnos_path(darcy), params: parametros }.to change { darcy.turnos.count }.by(1)

      expect(response).to redirect_to(admin_restaurante_turnos_path(darcy))
      follow_redirect!
      expect(response.body).to include("Turno cadastrado")
    end

    it "não cadastra um turno com término antes do início" do
      parametros[:turno].merge!(hora_inicio: "14:00", hora_fim: "11:00")

      expect { post admin_restaurante_turnos_path(darcy), params: parametros }.not_to change(Turno, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("O horário de término deve ser posterior ao de início")
    end

    it "não cadastra um turno sobreposto" do
      darcy.turnos.create!(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00")
      parametros[:turno].merge!(nome: "jantar", hora_inicio: "13:30", hora_fim: "19:30")

      expect { post admin_restaurante_turnos_path(darcy), params: parametros }.not_to change(Turno, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("O horário conflita com o turno almoço")
    end
  end
end
