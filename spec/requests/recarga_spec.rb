require "rails_helper"

RSpec.describe "Recarga de saldo", type: :request do
  let!(:user) do
    User.create!(nome: "Ana Beatriz Silva", matricula: "221045999", password: "Senha123", saldo_centavos: 1800)
  end

  def entrar
    post login_path, params: { matricula: "221045999", password: "Senha123" }
  end

  it "exige que o estudante esteja autenticado" do
    get recarga_path

    expect(response).to redirect_to(login_path)
  end

  describe "GET /recarga" do
    before { entrar }

    it "mostra o saldo atual e os pacotes" do
      get recarga_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("R$ 18,00", "4 refs")
      expect(response.body).to include("2 Refeições", "5 Refeições", "10 Refeições", "20 Refeições")
    end

    it "não mostra resumo nem permite confirmar sem uma quantidade escolhida" do
      get recarga_path

      expect(response.body).to include("Escolha um pacote")
      expect(response.body).not_to include("Confirmar")
    end

    it "monta o resumo com a quantidade escolhida" do
      get recarga_path(quantidade: 5)

      expect(response.body).to include("5 refeições", "R$ 22,50", "9 refs (R$ 40,50)")
    end

    it "mostra o QR Code e a chave copia e cola com o PIX" do
      get recarga_path(quantidade: 5, metodo: "pix")

      expect(response.body).to include("QR Code PIX", "Copiar Código", "000201")
    end

    it "não mostra o QR Code com cartão de crédito" do
      get recarga_path(quantidade: 5, metodo: "cartao")

      expect(response.body).not_to include("QR Code PIX")
      expect(response.body).to include("Cartão de Crédito")
    end

    it "ignora quantidades inválidas na URL" do
      get recarga_path(quantidade: -3, metodo: "boleto")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Escolha um pacote")
    end
  end

  describe "POST /recarga" do
    before { entrar }

    it "confirma a recarga e soma os créditos ao saldo" do
      expect { post recarga_path, params: { quantidade: 5, metodo: "pix" } }.to change(Recarga, :count).by(1)

      expect(user.reload.saldo_centavos).to eq(4050)
      expect(response).to redirect_to(recarga_path)
      follow_redirect!
      expect(response.body).to include("Recarga confirmada", "R$ 40,50")
    end

    it "não altera o saldo com uma quantidade inválida" do
      expect { post recarga_path, params: { quantidade: 0, metodo: "pix" } }.not_to change(Recarga, :count)

      expect(user.reload.saldo_centavos).to eq(1800)
      expect(response).to redirect_to(recarga_path)
      follow_redirect!
      expect(response.body).to include("Não foi possível confirmar a recarga")
    end
  end
end
