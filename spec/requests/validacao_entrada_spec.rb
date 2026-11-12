require "rails_helper"

RSpec.describe "Validação de entrada no terminal", type: :request do
  let!(:funcionario) { Funcionario.create!(nome: "Carlos Mendes", matricula: "1984201", password: "Operador123") }
  let!(:estudante) { User.create!(nome: "Mariana Souza Silva", matricula: "100001", password: "Senha123", saldo_centavos: 1000) }

  before { Tarifa.create!(valor_centavos: 600) }

  def entrar(matricula = "1984201")
    post operador_login_path, params: { login_operador: { matricula:, password: "Operador123" } }
  end

  def ler(identificacao)
    post operador_acessos_path, params: { identificacao: }
  end

  it "exige um operador autenticado para ler identificações" do
    expect { ler("100001") }.not_to change(Acesso, :count)

    expect(response).to redirect_to(operador_login_path)
  end

  describe "GET /operador/terminal" do
    before { entrar }

    it "mostra o leitor e a tarifa vigente" do
      get operador_terminal_path

      expect(response.body).to include("Identificação do estudante", "Ler identificação", "R$ 6,00")
      expect(response.body).to include("Aguardando leitura")
    end
  end

  describe "POST /operador/acessos" do
    before { entrar }

    it "libera a catraca sem debitar e pede a confirmação da passagem" do
      ler("100001")

      expect(response).to redirect_to(operador_terminal_path(acesso: Acesso.last.id))
      follow_redirect!
      expect(response.body).to include("Acesso liberado", "Mariana Souza Silva", "Confirmar passagem")
      expect(estudante.reload.saldo_centavos).to eq(1000)
    end

    it "nega a entrada por saldo insuficiente" do
      estudante.update!(saldo_centavos: 599)

      ler("100001")
      follow_redirect!

      expect(response.body).to include("Acesso negado", "Saldo insuficiente")
      expect(response.body).not_to include("Confirmar passagem")
    end

    it "nega a entrada de um estudante desconhecido" do
      ler("999999")
      follow_redirect!

      expect(response.body).to include("Acesso negado", "Estudante não encontrado", "999999")
    end

    it "pede a identificação quando a leitura vem vazia" do
      expect { ler(" ") }.not_to change(Acesso, :count)

      follow_redirect!
      expect(response.body).to include("Informe a identificação do estudante")
    end

    it "lista a leitura nas últimas validações" do
      ler("100001")
      follow_redirect!

      expect(response.body).to include("Últimas Validações Registradas", "100001")
    end
  end

  describe "POST /operador/acessos/:id/passagem" do
    before { entrar }

    it "debita a refeição e mostra o saldo restante" do
      ler("100001")

      post operador_acesso_passagem_path(Acesso.last)

      expect(estudante.reload.saldo_centavos).to eq(400)
      follow_redirect!
      expect(response.body).to include("Passagem confirmada", "Saldo restante: R$ 4,00")
    end

    it "não debita duas vezes" do
      ler("100001")
      acesso = Acesso.last

      2.times { post operador_acesso_passagem_path(acesso) }

      expect(estudante.reload.saldo_centavos).to eq(400)
    end

    it "não deixa um operador confirmar a leitura de outro" do
      ler("100001")
      acesso = Acesso.last
      Funcionario.create!(nome: "Outro Operador", matricula: "1984202", password: "Operador123")
      entrar("1984202")

      post operador_acesso_passagem_path(acesso)

      expect(response).to have_http_status(:not_found)
      expect(estudante.reload.saldo_centavos).to eq(1000)
    end
  end
end
