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

  it "lista só os restaurantes com turnos cadastrados" do
    darcy = Restaurante.create!(nome: "Darcy Ribeiro")
    Restaurante.create!(nome: "Gama")
    darcy.turnos.create!(nome: "almoço", hora_inicio: "11:00", hora_fim: "14:00")
    darcy.turnos.create!(nome: "jantar", hora_inicio: "18:00", hora_fim: "20:00")

    expect(Restaurante.com_turnos).to eq([ darcy ])
  end

  describe ".selecao_obrigatoria?" do
    it "não exige a seleção quando não há restaurantes" do
      expect(Restaurante.selecao_obrigatoria?).to be(false)
    end

    it "exige a seleção quando há restaurantes cadastrados" do
      Restaurante.create!(nome: "Darcy Ribeiro")

      expect(Restaurante.selecao_obrigatoria?).to be(true)
    end
  end
end
