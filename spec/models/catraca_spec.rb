require "rails_helper"

RSpec.describe Catraca, type: :model do
  let(:darcy) { Restaurante.create!(nome: "Darcy Ribeiro") }
  let(:gama) { Restaurante.create!(nome: "Gama") }

  it "pertence a um restaurante" do
    expect(Catraca.new(nome: "Entrada 1")).not_to be_valid
    expect(darcy.catracas.new(nome: "Entrada 1")).to be_valid
  end

  it "exige um nome" do
    expect(darcy.catracas.new(nome: "")).not_to be_valid
  end

  it "não repete o nome dentro do mesmo restaurante" do
    darcy.catracas.create!(nome: "Entrada 1")

    expect(darcy.catracas.new(nome: "Entrada 1")).not_to be_valid
    expect(gama.catracas.new(nome: "Entrada 1")).to be_valid
  end
end
