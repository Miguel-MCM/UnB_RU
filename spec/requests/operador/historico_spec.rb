require "rails_helper"

RSpec.describe "Histórico local da catraca", type: :request do
  let!(:funcionario) { Funcionario.create!(nome: "Carlos Mendes", matricula: "1984201", password: "Operador123") }
  let!(:restaurante) { Restaurante.create!(nome: "Darcy Ribeiro") }
  let!(:catraca1) { restaurante.catracas.create!(nome: "Entrada 1") }
  let!(:catraca2) { restaurante.catracas.create!(nome: "Entrada 2") }
  let!(:estudante1) { User.create!(nome: "Estudante 1", matricula: "100001", password: "Senha123", saldo_centavos: 1000) }
  let!(:estudante2) { User.create!(nome: "Estudante 2", matricula: "100002", password: "Senha123", saldo_centavos: 1000) }

  before do
    Tarifa.create!(valor_centavos: 600)
    post operador_login_path, params: { login_operador: { matricula: funcionario.matricula, password: funcionario.password } }
  end

  describe "GET /operador/historico" do
    it "exibe os acessos da catraca gerenciada" do
      Acesso.create!(catraca: catraca1, user: estudante1, funcionario:, identificacao: "100001", status: :confirmado, valor_centavos: 600)
      Acesso.create!(catraca: catraca2, user: estudante2, funcionario:, identificacao: "100002", status: :confirmado, valor_centavos: 600)

      get operador_historico_path(catraca_id: catraca1.id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("100001")
      expect(response.body).not_to include("100002")
    end

    it "exibe mensagem de histórico vazio quando não há acessos" do
      get operador_historico_path(catraca_id: catraca1.id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Nenhum acesso registrado")
    end

    it "exige autenticação do operador" do
      delete operador_logout_path
      get operador_historico_path

      expect(response).to redirect_to(operador_login_path)
    end
  end
end
