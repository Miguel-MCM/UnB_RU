require "rails_helper"

RSpec.describe "Página de autenticação", type: :request do
  describe "GET /login" do
    it "responde com sucesso e oferece o link para o cadastro" do
      get login_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(%(href="#{signup_path}"))
    end
  end
end
