require "rails_helper"

RSpec.describe Sorteio, type: :model do
  let(:almoco) { Restaurante.create!(nome: "Darcy Ribeiro").turnos.create!(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00") }

  describe ".do_dia!" do
    it "cria o sorteio do dia aberto para inscrições" do
      sorteio = Sorteio.do_dia!(almoco)

      expect(sorteio).to be_persisted
      expect(sorteio).to be_aberto
      expect(sorteio).to be_inscricoes_abertas
      expect(sorteio.data_refeicao).to eq(Date.current)
    end

    it "é idempotente para o mesmo turno e dia" do
      primeiro = Sorteio.do_dia!(almoco)

      expect(Sorteio.do_dia!(almoco)).to eq(primeiro)
      expect(Sorteio.count).to eq(1)
    end

    it "busca o sorteio criado por outra requisição quando perde a corrida" do
      existente = Sorteio.create!(turno: almoco, data_refeicao: Date.current)
      allow(Sorteio).to receive(:find_or_create_by!).and_raise(ActiveRecord::RecordInvalid.new(Sorteio.new))

      expect(Sorteio.do_dia!(almoco)).to eq(existente)
    end

    it "deixa o erro subir quando a falha não é de corrida" do
      allow(Sorteio).to receive(:find_or_create_by!).and_raise(ActiveRecord::RecordInvalid.new(Sorteio.new))

      expect { Sorteio.do_dia!(almoco) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "cria um sorteio por dia" do
      expect(Sorteio.do_dia!(almoco, Date.current + 1)).not_to eq(Sorteio.do_dia!(almoco))
    end
  end

  it "não repete o sorteio do mesmo turno no mesmo dia" do
    Sorteio.do_dia!(almoco)

    expect(Sorteio.new(turno: almoco, data_refeicao: Date.current)).not_to be_valid
  end

  it "encerra as inscrições" do
    sorteio = Sorteio.do_dia!(almoco)
    sorteio.encerrar!

    expect(sorteio.reload).to be_encerrado
    expect(sorteio).not_to be_inscricoes_abertas
  end
end
