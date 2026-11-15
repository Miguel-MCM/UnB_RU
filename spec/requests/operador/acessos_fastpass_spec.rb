require "rails_helper"

RSpec.describe "Entrada do FastPass no terminal", type: :request do
  let!(:funcionario) { Funcionario.create!(nome: "Carlos Mendes", matricula: "1984201", password: "Operador123") }
  let!(:darcy) { Restaurante.create!(nome: "Darcy Ribeiro") }
  let!(:estudante) { User.create!(nome: "Mariana Souza Silva", matricula: "100001", password: "Senha123", saldo_centavos: 1000) }
  let(:almoco) { darcy.turnos.create!(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00").tap { |turno| turno.dividir_em_time_frames!(15) } }

  before do
    Tarifa.create!(valor_centavos: 600)
    travel_to Time.zone.local(2026, 11, 16, 8, 0)
    InscricaoFastpass.inscrever!(user: estudante, time_frame: almoco.time_frames.first).sorteado!
    travel_to Time.zone.local(2026, 11, 16, 11, 5)
    post operador_login_path, params: { login_operador: { matricula: funcionario.matricula, password: "Operador123" } }
  end

  after { travel_back }

  def selecionar_darcy
    patch operador_ponto_de_acesso_path, params: { restaurante_id: darcy.id }
  end

  it "exibe a entrada do FastPass no terminal" do
    selecionar_darcy
    get operador_terminal_path

    expect(response.body).to include("Entrada do FastPass", "Identificação no FastPass", "Validar FastPass")
  end

  it "registra a leitura na modalidade FastPass e libera o sorteado" do
    selecionar_darcy
    post operador_acessos_path, params: { identificacao: "100001", modalidade: "fastpass" }

    acesso = Acesso.last
    expect(response).to redirect_to(operador_terminal_path(acesso:))
    expect(acesso).to be_modalidade_fastpass
    expect(acesso).to be_liberado

    follow_redirect!
    expect(response.body).to include("Acesso liberado", "FastPass")
  end

  it "informa o motivo do bloqueio no terminal" do
    selecionar_darcy
    travel_to Time.zone.local(2026, 11, 16, 11, 20)
    post operador_acessos_path, params: { identificacao: "100001", modalidade: "fastpass" }
    follow_redirect!

    expect(Acesso.last).to be_fora_do_time_frame
    expect(response.body).to include("Acesso negado", "Fora do time-frame do FastPass", "O estudante deve voltar para o final da fila.")
    expect(response.body).to include("Bloqueado · fora do time-frame")
  end

  it "trata uma modalidade inválida como entrada comum" do
    selecionar_darcy
    post operador_acessos_path, params: { identificacao: "100001", modalidade: "vip" }

    expect(Acesso.last).to be_modalidade_comum
  end

  it "exige a seleção do restaurante antes da leitura" do
    post operador_acessos_path, params: { identificacao: "100001", modalidade: "fastpass" }

    expect(response).to redirect_to(operador_ponto_de_acesso_path)
    expect(Acesso.count).to eq(0)
  end
end
