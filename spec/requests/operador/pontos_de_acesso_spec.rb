require "rails_helper"

RSpec.describe "Configuração do ponto de acesso", type: :request do
  let!(:funcionario) { Funcionario.create!(nome: "Carlos Mendes", matricula: "1984201", password: "Operador123") }
  let!(:darcy) { Restaurante.create!(nome: "Darcy Ribeiro") }
  let!(:gama) { Restaurante.create!(nome: "Gama") }
  let!(:estudante) { User.create!(nome: "Mariana Souza Silva", matricula: "100001", password: "Senha123", saldo_centavos: 1000) }

  before { Tarifa.create!(valor_centavos: 600) }

  def entrar
    post operador_login_path, params: { login_operador: { matricula: funcionario.matricula, password: "Operador123" } }
  end

  def selecionar(restaurante)
    patch operador_ponto_de_acesso_path, params: { restaurante_id: restaurante.id }
  end

  def ler(identificacao)
    post operador_acessos_path, params: { identificacao: }
  end

  describe "GET /operador/ponto_de_acesso" do
    it "lista os restaurantes disponíveis" do
      entrar
      get operador_ponto_de_acesso_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Selecione o restaurante", "Darcy Ribeiro", "Gama")
    end

    it "exige autenticação do operador" do
      get operador_ponto_de_acesso_path

      expect(response).to redirect_to(operador_login_path)
    end
  end

  describe "PATCH /operador/ponto_de_acesso" do
    before { entrar }

    it "grava o restaurante na sessão e libera o terminal" do
      selecionar(darcy)

      expect(response).to redirect_to(operador_terminal_path)
      expect(session[:restaurante_id]).to eq(darcy.id)
      expect(flash[:notice]).to eq("Ponto de acesso configurado para o restaurante Darcy Ribeiro.")

      get operador_terminal_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("ponto-de-acesso", "Darcy Ribeiro")
    end

    it "descarta a catraca de outro restaurante" do
      catraca = darcy.catracas.create!(nome: "Entrada 1")
      get operador_terminal_path(catraca_id: catraca.id)

      selecionar(gama)

      expect(session[:catraca_id]).to be_nil
      expect(session[:restaurante_id]).to eq(gama.id)
    end

    it "mantém a catraca do mesmo restaurante" do
      catraca = darcy.catracas.create!(nome: "Entrada 1")
      get operador_terminal_path(catraca_id: catraca.id)

      selecionar(darcy)

      expect(session[:catraca_id]).to eq(catraca.id)
    end

    it "responde 404 para um restaurante inexistente" do
      selecionar(Restaurante.new(id: 0))

      expect(response).to have_http_status(:not_found)
      expect(session[:restaurante_id]).to be_nil
    end

    it "exige autenticação do operador" do
      delete operador_logout_path
      selecionar(darcy)

      expect(response).to redirect_to(operador_login_path)
    end
  end

  describe "exigência da seleção" do
    before { entrar }

    it "redireciona o terminal para a seleção quando nenhum restaurante foi escolhido" do
      get operador_terminal_path

      expect(response).to redirect_to(operador_ponto_de_acesso_path)
      expect(flash[:alert]).to eq("Selecione o restaurante antes de iniciar a operação.")
    end

    it "volta para a seleção quando o restaurante da sessão foi removido" do
      selecionar(gama)
      gama.destroy

      get operador_terminal_path

      expect(response).to redirect_to(operador_ponto_de_acesso_path)
    end

    it "mostra o aviso de ponto de acesso não configurado só nas telas de operação" do
      get operador_ponto_de_acesso_path
      expect(response.body).to include("Ponto de acesso não configurado")

      Restaurante.destroy_all
      get operador_terminal_path
      expect(response.body).not_to include("Ponto de acesso não configurado")
    end

    it "não registra leituras antes da seleção" do
      expect { ler("100001") }.not_to change(Acesso, :count)

      expect(response).to redirect_to(operador_ponto_de_acesso_path)
    end

    it "associa as leituras ao restaurante selecionado" do
      selecionar(gama)
      ler("100001")

      expect(Acesso.last.restaurante).to eq(gama)
    end

    it "define o restaurante pela catraca escolhida" do
      catraca = gama.catracas.create!(nome: "Entrada 1")

      get operador_terminal_path(catraca_id: catraca.id)

      expect(response).to have_http_status(:ok)
      expect(session[:restaurante_id]).to eq(gama.id)

      ler("100001")
      expect(Acesso.last).to have_attributes(restaurante: gama, catraca:)
    end

    it "funciona como antes quando não há restaurantes cadastrados" do
      Restaurante.destroy_all

      get operador_terminal_path
      expect(response).to have_http_status(:ok)

      expect { ler("100001") }.to change(Acesso, :count).by(1)
      expect(Acesso.last.restaurante).to be_nil
    end
  end
end
