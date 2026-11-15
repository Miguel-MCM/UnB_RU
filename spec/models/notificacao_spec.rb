require "rails_helper"

RSpec.describe Notificacao, type: :model do
  let(:almoco) do
    Restaurante.create!(nome: "Darcy Ribeiro").turnos
      .create!(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00").tap { |turno| turno.dividir_em_time_frames!(15) }
  end
  let(:estudante) { User.create!(nome: "Mariana Souza Silva", matricula: "100001", password: "Senha123") }
  let(:inscricao) { InscricaoFastpass.inscrever!(user: estudante, time_frame: almoco.time_frames.first) }

  def notificacao(**atributos)
    Notificacao.new(user: estudante, inscricao_fastpass: inscricao, tipo: :contemplado,
                    mensagem: "Você ganhou o FastPass", enviada_em: Time.current, **atributos)
  end

  it "é válida com usuário, inscrição, tipo, mensagem e data de envio" do
    expect(notificacao).to be_valid
    expect(notificacao).not_to be_lida
  end

  it "exige mensagem, tipo e data de envio" do
    expect(notificacao(mensagem: "")).not_to be_valid
    expect(notificacao(tipo: nil)).not_to be_valid
    expect(notificacao(enviada_em: nil)).not_to be_valid
  end

  it "é única por inscrição" do
    notificacao.save!

    duplicada = notificacao
    expect(duplicada).not_to be_valid
    expect(duplicada.errors[:inscricao_fastpass_id]).to be_present
  end

  it "ordena das mais recentes para as mais antigas" do
    antiga = notificacao(enviada_em: 2.days.ago).tap(&:save!)
    jantar = almoco.restaurante.turnos.create!(nome: "jantar", hora_inicio: "17:00", hora_fim: "20:00").tap { |turno| turno.dividir_em_time_frames!(15) }
    outra = InscricaoFastpass.inscrever!(user: estudante, time_frame: jantar.time_frames.first)
    recente = notificacao(inscricao_fastpass: outra, enviada_em: 1.hour.ago).tap(&:save!)

    expect(estudante.notificacoes.recentes).to eq([ recente, antiga ])
  end

  it "é removida com o usuário" do
    notificacao.save!

    expect { estudante.destroy }.to change(Notificacao, :count).by(-1)
  end
end
