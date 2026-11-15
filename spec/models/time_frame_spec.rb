require "rails_helper"

RSpec.describe TimeFrame, type: :model do
  let(:turno) do
    Restaurante.create!(nome: "Darcy Ribeiro").turnos.create!(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00")
  end

  it "pertence a um turno e exige número e horários" do
    expect(TimeFrame.new(numero: 1, hora_inicio: "11:00", hora_fim: "11:15")).not_to be_valid
    expect(turno.time_frames.new(hora_inicio: "11:00", hora_fim: "11:15")).not_to be_valid
    expect(turno.time_frames.new(numero: 1)).not_to be_valid
    expect(turno.time_frames.new(numero: 1, hora_inicio: "11:00", hora_fim: "11:15")).to be_valid
  end

  it "exibe o horário no formato HH:MM" do
    time_frame = turno.time_frames.new(numero: 1, hora_inicio_min: 660, hora_fim_min: 675)

    expect(time_frame).to have_attributes(hora_inicio: "11:00", hora_fim: "11:15", horario: "11:00 às 11:15")
  end

  describe "#cobre?" do
    let(:time_frame) { turno.time_frames.new(numero: 1, hora_inicio: "11:00", hora_fim: "11:15") }

    it "cobre do minuto de início ao de término, inclusive" do
      expect(time_frame.cobre?(660)).to be(true)
      expect(time_frame.cobre?(665)).to be(true)
      expect(time_frame.cobre?(675)).to be(true)
    end

    it "não cobre minutos fora do intervalo" do
      expect(time_frame.cobre?(659)).to be(false)
      expect(time_frame.cobre?(676)).to be(false)
    end
  end
end
