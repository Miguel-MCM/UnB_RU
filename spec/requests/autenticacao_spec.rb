require "rails_helper"

RSpec.describe "Autenticação do estudante", type: :request do
  let!(:user) { User.create!(nome: "Ana Beatriz Silva", matricula: "221045999", password: "Senha123") }

  describe "GET /login" do
    it "exibe o formulário e o link para o cadastro" do
      get login_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Matrícula SIGAA ou SIAPE", "Senha de Acesso", "Entrar no Sistema")
      expect(response.body).to include(%(href="#{signup_path}"))
    end
  end

  describe "POST /login" do
    it "inicia a sessão e leva para a recarga" do
      post login_path, params: { matricula: "221045999", password: "Senha123" }

      expect(response).to redirect_to(recarga_path)
      follow_redirect!
      expect(response.body).to include("Ana Beatriz Silva")
    end

    it "recusa a senha errada" do
      post login_path, params: { matricula: "221045999", password: "errada" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Matrícula ou senha inválidas")
    end
  end

  describe "DELETE /logout" do
    it "encerra a sessão" do
      post login_path, params: { matricula: "221045999", password: "Senha123" }

      delete logout_path

      expect(response).to redirect_to(login_path)
      get recarga_path
      expect(response).to redirect_to(login_path)
    end
  end
end
