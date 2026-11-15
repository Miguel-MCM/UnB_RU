require "rails_helper"

RSpec.describe Restaurante, type: :model do
  it "exige um nome" do
    restaurante = Restaurante.new(nome: " ")

    expect(restaurante).not_to be_valid
    expect(restaurante.errors[:nome]).to include("não pode ficar em branco")
  end

  it "não permite dois restaurantes com o mesmo nome" do
    Restaurante.create!(nome: "Darcy Ribeiro")

    expect(Restaurante.new(nome: " Darcy Ribeiro ")).not_to be_valid
  end

  it "remove as catracas junto com o restaurante" do
    restaurante = Restaurante.create!(nome: "Darcy Ribeiro")
    restaurante.catracas.create!(nome: "Entrada 1")

    expect { restaurante.destroy }.to change(Catraca, :count).by(-1)
  end

  it "lista os restaurantes em ordem alfabética" do
    Restaurante.create!(nome: "Gama")
    Restaurante.create!(nome: "Darcy Ribeiro")

    expect(Restaurante.ordenados.map(&:nome)).to eq([ "Darcy Ribeiro", "Gama" ])
  end
end
