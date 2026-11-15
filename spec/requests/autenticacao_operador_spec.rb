require "rails_helper"

RSpec.describe "Autenticação do operador", type: :request do
  let!(:funcionario) { Funcionario.create!(nome: "Carlos Mendes", matricula: "1984201", password: "Operador123") }

  def entrar(matricula: "1984201", password: "Operador123")
    post operador_login_path, params: { login_operador: { matricula:, password: } }
  end

  describe "GET /operador/login" do
    it "exibe o formulário com os campos obrigatórios sinalizados" do
      get operador_login_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Autenticação do Operador", "Matrícula SIAPE ou Usuário SIGAA / gov.br", "Senha de Acesso")
      expect(response.body.scan("Obrigatório").size).to eq(2)
      expect(response.body.scan("required").size).to be >= 2
    end
  end

  describe "POST /operador/login" do
    it "inicia a sessão e libera o terminal" do
      entrar

      expect(response).to redirect_to(operador_terminal_path)
      follow_redirect!
      expect(response.body).to include("Carlos Mendes", "Terminal liberado para operação")
    end

    it "mostra as mensagens de campo obrigatório quando os campos vêm em branco" do
      entrar(matricula: "", password: "")

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body.scan("Campo obrigatório").size).to eq(2)
    end

    it "recusa credenciais erradas e mantém a matrícula digitada" do
      entrar(password: "errada")

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Matrícula ou senha inválidas", %(value="1984201"))
      expect(response.body).not_to include("errada")
    end
  end

  describe "GET /operador/terminal" do
    it "exige um operador autenticado" do
      get operador_terminal_path

      expect(response).to redirect_to(operador_login_path)
    end

    it "não aceita a sessão de um estudante" do
      User.create!(nome: "Ana Beatriz Silva", matricula: "221045999", password: "Senha123")
      post login_path, params: { matricula: "221045999", password: "Senha123" }

      get operador_terminal_path

      expect(response).to redirect_to(operador_login_path)
    end
  end

  describe "DELETE /operador/logout" do
    it "encerra a sessão do operador" do
      entrar

      delete operador_logout_path

      expect(response).to redirect_to(operador_login_path)
      get operador_terminal_path
      expect(response).to redirect_to(operador_login_path)
    end
  end
end
