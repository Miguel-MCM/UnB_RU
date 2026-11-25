require "rails_helper"

RSpec.describe "Gestão de catracas", type: :request do
  let!(:administrador) do
    Funcionario.create!(nome: "Fernando Albuquerque", matricula: "1083921", password: "Admin123", administrador: true)
  end
  let!(:operador) { Funcionario.create!(nome: "Carlos Mendes", matricula: "1984201", password: "Operador123") }
  let!(:darcy) { Restaurante.create!(nome: "Darcy Ribeiro") }
  let!(:entrada1) { darcy.catracas.create!(nome: "Entrada 1") }

  def entrar(funcionario, password)
    post operador_login_path, params: { login_operador: { matricula: funcionario.matricula, password: } }
  end

  describe "sem ser administrador" do
    it "redireciona para o login quando não há funcionário autenticado" do
      expect { post admin_restaurante_catracas_path(darcy), params: { catraca: { nome: "Entrada 2" } } }.not_to change(Catraca, :count)

      expect(response).to redirect_to(operador_login_path)
    end

    it "não deixa um operador comum cadastrar, editar nem remover" do
      entrar(operador, "Operador123")

      expect { post admin_restaurante_catracas_path(darcy), params: { catraca: { nome: "Entrada 2" } } }.not_to change(Catraca, :count)
      expect(response).to redirect_to(operador_terminal_path)

      patch admin_catraca_path(entrada1), params: { catraca: { nome: "Outra" } }
      expect(entrada1.reload.nome).to eq("Entrada 1")

      expect { delete admin_catraca_path(entrada1) }.not_to change(Catraca, :count)
    end
  end

  context "com o administrador autenticado" do
    before { entrar(administrador, "Admin123") }

    it "cadastra a catraca e avisa" do
      expect { post admin_restaurante_catracas_path(darcy), params: { catraca: { nome: "Entrada 2" } } }.to change { darcy.catracas.count }.by(1)

      follow_redirect!
      expect(response.body).to include("Catraca cadastrada")
    end

    it "não cadastra com nome em branco" do
      expect { post admin_restaurante_catracas_path(darcy), params: { catraca: { nome: " " } } }.not_to change(Catraca, :count)

      follow_redirect!
      expect(response.body).to include("Não foi possível adicionar a catraca")
    end

    it "não cadastra nome repetido no mesmo restaurante" do
      expect { post admin_restaurante_catracas_path(darcy), params: { catraca: { nome: "Entrada 1" } } }.not_to change(Catraca, :count)
    end

    it "responde 404 ao cadastrar em restaurante inexistente" do
      post admin_restaurante_catracas_path(restaurante_id: 0), params: { catraca: { nome: "Entrada 2" } }

      expect(response).to have_http_status(:not_found)
    end

    it "exibe o formulário de edição" do
      get edit_admin_catraca_path(entrada1)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Entrada 1")
    end

    it "atualiza o nome e avisa" do
      patch admin_catraca_path(entrada1), params: { catraca: { nome: "Entrada Norte" } }

      expect(entrada1.reload.nome).to eq("Entrada Norte")
      follow_redirect!
      expect(response.body).to include("Catraca atualizada")
    end

    it "não atualiza com nome em branco e re-renderiza a edição" do
      patch admin_catraca_path(entrada1), params: { catraca: { nome: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(entrada1.reload.nome).to eq("Entrada 1")
    end

    it "remove a catraca e mantém os acessos dela sem catraca" do
      acesso = Acesso.create!(funcionario: administrador, restaurante: darcy, catraca: entrada1, identificacao: "231012345", status: :confirmado, valor_centavos: 450)

      expect { delete admin_catraca_path(entrada1) }.to change(Catraca, :count).by(-1)

      expect(acesso.reload.catraca_id).to be_nil
      follow_redirect!
      expect(response.body).to include("Catraca removida")
    end

    it "responde 404 para catraca inexistente" do
      get edit_admin_catraca_path(id: 0)
      expect(response).to have_http_status(:not_found)

      delete admin_catraca_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end
  end
end
