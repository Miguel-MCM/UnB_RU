require "rails_helper"

RSpec.describe Turno, type: :model do
  let(:darcy) { Restaurante.create!(nome: "Darcy Ribeiro") }
  let(:gama) { Restaurante.create!(nome: "Gama") }
  let(:almoco) { darcy.turnos.create!(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00") }

  describe "horários" do
    it "converte HH:MM em minutos desde a meia-noite e de volta" do
      turno = Turno.new(hora_inicio: "11:00", hora_fim: "14:30")

      expect(turno).to have_attributes(hora_inicio_min: 660, hora_fim_min: 870, hora_inicio: "11:00", hora_fim: "14:30")
      expect(turno.horario).to eq("11:00 às 14:30")
    end

    it "ignora horários inválidos" do
      expect(Turno.new(hora_inicio: "25:00").hora_inicio_min).to be_nil
      expect(Turno.new(hora_inicio: "").hora_inicio_min).to be_nil
    end

    it "aceita segundos opcionais, ignorando-os" do
      expect(Turno.new(hora_inicio: "11:00:45")).to have_attributes(hora_inicio_min: 660, hora_inicio: "11:00")
      expect(Turno.new(hora_inicio: "11:00:7").hora_inicio_min).to be_nil
    end

    it "calcula a duração total" do
      expect(almoco.duracao_total_min).to eq(180)
    end
  end

  describe "validações" do
    it "exige restaurante, nome e horários" do
      expect(Turno.new(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00")).not_to be_valid
      expect(darcy.turnos.new(nome: "", hora_inicio: "11:00", hora_fim: "14:00")).not_to be_valid
      expect(darcy.turnos.new(nome: "almoço")).not_to be_valid
    end

    it "exige término posterior ao início" do
      turno = darcy.turnos.new(nome: "almoço", hora_inicio: "14:00", hora_fim: "11:00")

      expect(turno).not_to be_valid
      expect(turno.errors[:base]).to include("O horário de término deve ser posterior ao de início")
      expect(darcy.turnos.new(nome: "almoço", hora_inicio: "11:00", hora_fim: "11:00")).not_to be_valid
    end

    it "não repete o nome dentro do mesmo restaurante" do
      almoco

      expect(darcy.turnos.new(nome: "almoço", hora_inicio: "18:00", hora_fim: "20:00")).not_to be_valid
      expect(gama.turnos.new(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00")).to be_valid
    end

    it "recusa turnos sobrepostos no mesmo restaurante citando o conflitante" do
      almoco
      jantar = darcy.turnos.new(nome: "jantar", hora_inicio: "13:30", hora_fim: "19:30")

      expect(jantar).not_to be_valid
      expect(jantar.errors[:base]).to include("O horário conflita com o turno almoço")
      expect(darcy.turnos.new(nome: "lanche", hora_inicio: "12:00", hora_fim: "13:00")).not_to be_valid
      expect(darcy.turnos.new(nome: "estendido", hora_inicio: "10:00", hora_fim: "15:00")).not_to be_valid
    end

    it "aceita turnos encostados e turnos de outro restaurante no mesmo horário" do
      almoco

      expect(darcy.turnos.new(nome: "jantar", hora_inicio: "14:00", hora_fim: "19:30")).to be_valid
      expect(darcy.turnos.new(nome: "café", hora_inicio: "07:00", hora_fim: "11:00")).to be_valid
      expect(gama.turnos.new(nome: "jantar", hora_inicio: "13:30", hora_fim: "19:30")).to be_valid
    end

    it "permite atualizar o próprio turno sem conflitar consigo mesmo" do
      expect(almoco.update(hora_fim: "14:30")).to be(true)
    end
  end

  describe "#dividir_em_time_frames!" do
    it "divide o turno em time-frames de 15 minutos" do
      expect(almoco.dividir_em_time_frames!(15)).to be(true)

      expect(almoco.time_frames.size).to eq(12)
      expect(almoco.time_frames.first.horario).to eq("11:00 às 11:15")
      expect(almoco.time_frames.last.horario).to eq("13:45 às 14:00")
      expect(almoco.time_frames.map(&:numero)).to eq((1..12).to_a)
      expect(almoco.reload.duracao_time_frame_min).to eq(15)
    end

    it "redivide o turno substituindo os time-frames anteriores" do
      almoco.dividir_em_time_frames!(15)
      almoco.dividir_em_time_frames!(30)

      expect(TimeFrame.where(turno: almoco).count).to eq(6)
      expect(almoco.time_frames.reload.first.horario).to eq("11:00 às 11:30")
    end

    it "encurta o último time-frame quando a duração não divide o turno" do
      almoco.dividir_em_time_frames!(50)

      expect(almoco.time_frames.map(&:horario).last).to eq("13:30 às 14:00")
      expect(almoco.time_frames.size).to eq(4)
    end

    it "aceita uma duração igual à do turno" do
      expect(almoco.dividir_em_time_frames!(180)).to be(true)
      expect(almoco.time_frames.size).to eq(1)
    end

    it "não altera nada com uma duração maior que o turno" do
      almoco.dividir_em_time_frames!(15)

      expect(almoco.dividir_em_time_frames!(240)).to be(false)
      expect(almoco.errors[:base]).to include("A duração do time-frame não pode ser maior que a duração do turno")
      expect(almoco.duracao_time_frame_min).to eq(15)
      expect(almoco.reload.duracao_time_frame_min).to eq(15)
      expect(almoco.time_frames.count).to eq(12)
    end

    it "recusa a redivisão quando algum time-frame já possui inscrições no FastPass" do
      almoco.dividir_em_time_frames!(15)
      estudante = User.create!(nome: "Mariana Souza Silva", matricula: "100001", password: "Senha123")
      InscricaoFastpass.inscrever!(user: estudante, time_frame: almoco.time_frames.first)

      expect(almoco.dividir_em_time_frames!(30)).to be(false)
      expect(almoco.errors[:base]).to include("Não é possível redividir um turno que já possui inscrições no FastPass")
      expect(almoco.reload.duracao_time_frame_min).to eq(15)
      expect(almoco.time_frames.count).to eq(12)
      expect(InscricaoFastpass.count).to eq(1)
    end

    it "não altera nada com uma duração zero ou negativa" do
      expect(almoco.dividir_em_time_frames!(0)).to be(false)
      expect(almoco.dividir_em_time_frames!(-15)).to be(false)
      expect(almoco.time_frames.count).to eq(0)
    end
  end

  it "remove os time-frames junto com o turno" do
    almoco.dividir_em_time_frames!(15)

    expect { almoco.destroy }.to change(TimeFrame, :count).by(-12)
  end

  it "remove sorteios e inscrições junto com o turno" do
    almoco.dividir_em_time_frames!(15)
    estudante = User.create!(nome: "Mariana Souza Silva", matricula: "100001", password: "Senha123")
    InscricaoFastpass.inscrever!(user: estudante, time_frame: almoco.time_frames.first)

    expect { almoco.destroy }.to change(InscricaoFastpass, :count).by(-1).and change(Sorteio, :count).by(-1)
  end

  it "é listado pelo restaurante em ordem de horário" do
    jantar = darcy.turnos.create!(nome: "jantar", hora_inicio: "18:00", hora_fim: "20:00")
    almoco

    expect(darcy.turnos.reload).to eq([ almoco, jantar ])
  end
end
