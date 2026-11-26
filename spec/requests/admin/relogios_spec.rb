require "rails_helper"

RSpec.describe "Horário do sistema", type: :request do
  let!(:administrador) { Funcionario.create!(nome: "Fernando", matricula: "1083921", password: "Admin123", administrador: true) }
  let!(:operador) { Funcionario.create!(nome: "Carlos", matricula: "1984201", password: "Operador123") }

  before { Relogio.limpar_cache }
  after { Relogio.limpar_cache }

  def entrar(funcionario, senha)
    post operador_login_path, params: { login_operador: { matricula: funcionario.matricula, password: senha } }
  end

  context "com o ajuste ligado" do
    before { allow(Rails.configuration.x.relogio).to receive(:ajustavel).and_return(true) }

    it "mostra o horário e o formulário ao administrador" do
      entrar(administrador, "Admin123")
      get admin_relogio_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("horario-do-sistema", "Ajustar horário", "horário real")
      expect(response.body).to include("Horário do Sistema")
    end

    it "ajusta o horário e avisa na barra superior" do
      entrar(administrador, "Admin123")
      alvo = (Relogio.agora_real.in_time_zone + 1.day).strftime("%Y-%m-%dT%H:%M")

      patch admin_relogio_path, params: { relogio: { horario_simulado: alvo } }

      expect(response).to redirect_to(admin_relogio_path)
      expect(Relogio.deslocamento).to be_within(120).of(86_400)
      follow_redirect!
      expect(response.body).to include("Horário simulado", "Voltar ao horário real")
    end

    it "recusa um horário inválido com 422" do
      entrar(administrador, "Admin123")

      patch admin_relogio_path, params: { relogio: { horario_simulado: "lixo" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Data ou hora inválida")
      expect(Relogio.deslocamento).to eq(0)
    end

    it "volta ao horário real" do
      entrar(administrador, "Admin123")
      Relogio.atual.update!(deslocamento_segundos: 3600)

      delete admin_relogio_path

      expect(response).to redirect_to(admin_relogio_path)
      expect(Relogio.deslocamento).to eq(0)
    end

    it "avança e atrasa meia hora pelas setas do terminal" do
      entrar(administrador, "Admin123")
      get operador_terminal_path
      expect(response.body).to include("Avançar 30 minutos", "Voltar 30 minutos")

      patch deslocar_admin_relogio_path, params: { sentido: "mais" }, headers: { "HTTP_REFERER" => operador_terminal_url }
      expect(response).to redirect_to(operador_terminal_url)
      expect(Relogio.deslocamento).to eq(1800)

      patch deslocar_admin_relogio_path, params: { sentido: "menos" }
      expect(response).to redirect_to(admin_relogio_path)
      expect(Relogio.deslocamento).to eq(0)
    end

    it "mostra o relógio com as setas nas telas de administração" do
      restaurante = Restaurante.create!(nome: "Darcy Ribeiro")
      entrar(administrador, "Admin123")

      [ admin_restaurantes_path, admin_restaurante_turnos_path(restaurante), admin_relogio_path ].each do |caminho|
        get caminho

        expect(response.body).to include("Horário oficial", "Avançar 30 minutos", "Voltar 30 minutos"), caminho
      end
    end

    it "responde 400 para um sentido desconhecido" do
      entrar(administrador, "Admin123")

      patch deslocar_admin_relogio_path, params: { sentido: "muito" }

      expect(response).to have_http_status(:bad_request)
      expect(Relogio.deslocamento).to eq(0)
    end

    it "esconde as setas de quem não é administrador e nega o ajuste" do
      entrar(operador, "Operador123")
      get operador_terminal_path
      expect(response.body).not_to include("Avançar 30 minutos")

      patch deslocar_admin_relogio_path, params: { sentido: "mais" }
      expect(response).to redirect_to(operador_terminal_path)
      expect(Relogio.deslocamento).to eq(0)
    end

    it "nega a operadores que não são administradores" do
      entrar(operador, "Operador123")

      patch admin_relogio_path, params: { relogio: { horario_simulado: "2026-12-01T10:00" } }

      expect(response).to redirect_to(operador_terminal_path)
      expect(Relogio.deslocamento).to eq(0)
    end

    it "exige autenticação" do
      get admin_relogio_path

      expect(response).to redirect_to(operador_login_path)
    end
  end

  context "com o ajuste desligado (padrão fora do desenvolvimento)" do
    it "esconde as setas do terminal e responde 404 ao deslocar" do
      entrar(administrador, "Admin123")
      get operador_terminal_path
      expect(response.body).not_to include("Avançar 30 minutos")

      patch deslocar_admin_relogio_path, params: { sentido: "mais" }
      expect(response).to have_http_status(:not_found)
      expect(Relogio.deslocamento).to eq(0)
    end

    it "responde 404 e não altera o relógio" do
      entrar(administrador, "Admin123")

      get admin_relogio_path
      expect(response).to have_http_status(:not_found)

      patch admin_relogio_path, params: { relogio: { horario_simulado: "2026-12-01T10:00" } }
      expect(response).to have_http_status(:not_found)
      expect(Relogio.deslocamento).to eq(0)
    end
  end
end
