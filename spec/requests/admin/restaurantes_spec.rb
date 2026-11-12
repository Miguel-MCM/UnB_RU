require "rails_helper"

RSpec.describe "Gestão de restaurantes e catracas", type: :request do
  let!(:administrador) do
    Funcionario.create!(nome: "Fernando Albuquerque", matricula: "1083921", password: "Admin123", administrador: true)
  end
  let!(:operador) { Funcionario.create!(nome: "Carlos Mendes", matricula: "1984201", password: "Operador123") }
  let!(:darcy) { Restaurante.create!(nome: "Darcy Ribeiro") }

  def entrar(funcionario, password)
    post operador_login_path, params: { login_operador: { matricula: funcionario.matricula, password: } }
  end

  describe "acesso" do
    it "exige um funcionário autenticado" do
      get admin_restaurantes_path

      expect(response).to redirect_to(operador_login_path)
    end

    it "não deixa um operador comum gerenciar restaurantes" do
      entrar(operador, "Operador123")

      expect { post admin_restaurantes_path, params: { restaurante: { nome: "Gama" } } }.not_to change(Restaurante, :count)
      expect(response).to redirect_to(operador_terminal_path)
    end

    it "leva o administrador para a gestão depois do login" do
      entrar(administrador, "Admin123")

      expect(response).to redirect_to(admin_restaurantes_path)
    end
  end

  context "com o administrador autenticado" do
    before { entrar(administrador, "Admin123") }

    it "lista os restaurantes com as catracas e os totais" do
      darcy.catracas.create!(nome: "Entrada 1")
      Restaurante.create!(nome: "Gama")

      get admin_restaurantes_path

      expect(response.body).to include("Gestão de Restaurantes e Catracas", "Darcy Ribeiro", "Gama", "Entrada 1")
      expect(response.body).to include("2 Unidades", "1 Catraca")
    end

    it "cadastra um restaurante" do
      expect { post admin_restaurantes_path, params: { restaurante: { nome: "Gama" } } }.to change(Restaurante, :count).by(1)

      expect(response).to redirect_to(admin_restaurantes_path)
      follow_redirect!
      expect(response.body).to include("Restaurante cadastrado")
    end

    it "não cadastra um restaurante com nome repetido" do
      expect { post admin_restaurantes_path, params: { restaurante: { nome: "Darcy Ribeiro" } } }.not_to change(Restaurante, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("já está em uso")
    end

    it "renomeia um restaurante" do
      patch admin_restaurante_path(darcy), params: { restaurante: { nome: "RU Darcy Ribeiro" } }

      expect(darcy.reload.nome).to eq("RU Darcy Ribeiro")
      expect(response).to redirect_to(admin_restaurantes_path)
    end

    it "não salva um nome em branco" do
      patch admin_restaurante_path(darcy), params: { restaurante: { nome: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(darcy.reload.nome).to eq("Darcy Ribeiro")
    end

    it "remove um restaurante e as catracas dele" do
      darcy.catracas.create!(nome: "Entrada 1")

      expect { delete admin_restaurante_path(darcy) }.to change(Restaurante, :count).by(-1).and change(Catraca, :count).by(-1)
    end

    it "cadastra uma catraca no restaurante" do
      expect { post admin_restaurante_catracas_path(darcy), params: { catraca: { nome: "Entrada 1" } } }
        .to change { darcy.catracas.count }.by(1)

      expect(response).to redirect_to(admin_restaurantes_path)
    end

    it "avisa quando a catraca não pode ser cadastrada" do
      darcy.catracas.create!(nome: "Entrada 1")

      post admin_restaurante_catracas_path(darcy), params: { catraca: { nome: "Entrada 1" } }
      follow_redirect!

      expect(response.body).to include("Não foi possível adicionar a catraca")
    end

    it "renomeia uma catraca sem mudar o restaurante" do
      catraca = darcy.catracas.create!(nome: "Entrada 1")

      patch admin_catraca_path(catraca), params: { catraca: { nome: "Entrada 2" } }

      expect(catraca.reload).to have_attributes(nome: "Entrada 2", restaurante: darcy)
      expect(response).to redirect_to(admin_restaurantes_path)
    end

    it "remove uma catraca" do
      catraca = darcy.catracas.create!(nome: "Entrada 1")

      expect { delete admin_catraca_path(catraca) }.to change(Catraca, :count).by(-1)
    end
  end
end
