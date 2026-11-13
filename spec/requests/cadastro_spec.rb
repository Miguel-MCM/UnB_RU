require "rails_helper"

RSpec.describe "Cadastro de usuário", type: :request do
  let(:params_validos) do
    {
      user: {
        nome: "João da Silva",
        matricula: "2023123456",
        password: "SenhaForte123",
        password_confirmation: "SenhaForte123"
      }
    }
  end

  describe "GET /cadastro" do
    it "exibe o formulário com os campos obrigatórios" do
      get signup_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Nome Completo", "Matrícula SIGAA ou SIAPE", "Senha de Acesso", "Confirmar Senha")
      expect(response.body).to include("Criar Minha Conta")
    end

    it "tem o link para a página de autenticação" do
      get signup_path

      expect(response.body).to include(%(href="#{login_path}"), "Já possui uma conta? Acesse aqui")
    end
  end

  describe "POST /cadastro" do
    it "cria a conta e redireciona para a autenticação com a confirmação" do
      expect { post signup_path, params: params_validos }.to change(User, :count).by(1)

      expect(response).to redirect_to(login_path)
      follow_redirect!
      expect(response.body).to include("Conta criada com sucesso")
    end

    it "não cria a conta quando as senhas não conferem" do
      params_validos[:user][:password_confirmation] = "OutraSenha Diferente"

      expect { post signup_path, params: params_validos }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("As senhas não conferem")
    end

    it "não cria a conta quando a matrícula já está cadastrada" do
      User.create!(params_validos[:user])

      expect { post signup_path, params: params_validos }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("já possui uma conta cadastrada")
    end

    it "mantém os dados preenchidos, menos as senhas, quando há erro" do
      params_validos[:user][:password_confirmation] = "OutraSenha Diferente"

      post signup_path, params: params_validos

      expect(response.body).to include(%(value="João da Silva"), %(value="2023123456"))
      expect(response.body).not_to include("SenhaForte123")
    end
  end
end
