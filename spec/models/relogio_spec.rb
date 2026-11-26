require "rails_helper"

RSpec.describe Relogio, type: :model do
  before { described_class.limpar_cache }
  after { described_class.limpar_cache }

  describe ".atual" do
    it "cria o registro único zerado e o reaproveita" do
      relogio = described_class.atual

      expect(relogio.deslocamento_segundos).to eq(0)
      expect(described_class.atual).to eq(relogio)
      expect(described_class.count).to eq(1)
    end
  end

  describe "#ajustar_para" do
    it "grava o deslocamento até o horário informado" do
      alvo = described_class.agora_real.in_time_zone + 2.hours

      expect(described_class.atual.ajustar_para(alvo.strftime("%Y-%m-%dT%H:%M"))).to be(true)

      expect(described_class.deslocamento).to be_within(60).of(7200)
      expect(described_class.atual.horario_do_sistema).to be_within(2.minutes).of(alvo)
    end

    it "aceita um horário no passado" do
      described_class.atual.ajustar_para((described_class.agora_real.in_time_zone - 1.day).strftime("%Y-%m-%dT%H:%M"))

      expect(described_class.deslocamento).to be_within(60).of(-86_400)
    end

    it "recusa texto vazio sem alterar o relógio" do
      relogio = described_class.atual

      expect(relogio.ajustar_para("  ")).to be(false)
      expect(relogio.errors[:horario_simulado]).to eq([ "Informe a data e a hora" ])
      expect(described_class.deslocamento).to eq(0)
    end

    it "recusa texto inválido sem alterar o relógio" do
      relogio = described_class.atual

      expect(relogio.ajustar_para("99:99")).to be(false)
      expect(relogio.ajustar_para("lixo")).to be(false)
      expect(relogio.errors[:horario_simulado]).to eq([ "Data ou hora inválida" ])
      expect(described_class.deslocamento).to eq(0)
    end
  end

  describe "#deslocar!" do
    it "avança e atrasa o relógio em meia hora" do
      relogio = described_class.atual

      relogio.deslocar!("mais")
      relogio.deslocar!("mais")
      expect(described_class.deslocamento).to eq(3600)

      relogio.deslocar!("menos")
      expect(described_class.deslocamento).to eq(1800)
    end

    it "recusa um sentido desconhecido sem alterar o relógio" do
      expect { described_class.atual.deslocar!("muito") }.to raise_error(KeyError)
      expect(described_class.deslocamento).to eq(0)
    end
  end

  describe "#restaurar!" do
    it "volta ao horário real" do
      relogio = described_class.atual
      relogio.ajustar_para((described_class.agora_real.in_time_zone + 1.day).strftime("%Y-%m-%dT%H:%M"))

      expect(relogio.restaurar!).to be(true)

      expect(described_class.deslocamento).to eq(0)
    end
  end

  describe ".ajustado?" do
    it "só vale com o ajuste ligado e deslocamento diferente de zero" do
      described_class.atual.update!(deslocamento_segundos: 3600)
      described_class.limpar_cache

      expect(described_class.ajustado?).to be(false)

      allow(Rails.configuration.x.relogio).to receive(:ajustavel).and_return(true)
      expect(described_class.ajustado?).to be(true)
    end
  end

  describe ".deslocamento" do
    it "vale 0 quando a tabela não existe" do
      allow(described_class).to receive(:first).and_raise(ActiveRecord::StatementInvalid)

      expect(described_class.deslocamento).to eq(0)
    end

    it "reaproveita a leitura dentro da validade do cache" do
      described_class.atual.update!(deslocamento_segundos: 60)
      described_class.limpar_cache
      described_class.deslocamento
      described_class.first.update_columns(deslocamento_segundos: 120)

      expect(described_class.deslocamento).to eq(60)
    end
  end
end
