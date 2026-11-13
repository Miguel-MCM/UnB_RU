require "rails_helper"

RSpec.describe Recarga, type: :model do
  let(:user) { User.create!(nome: "Ana Beatriz Silva", matricula: "221045999", password: "Senha123") }

  it "calcula o valor pela tarifa única de R$ 4,50" do
    recarga = Recarga.new(user:, quantidade: 5, metodo_pagamento: "pix")

    expect(recarga).to be_valid
    expect(recarga.valor_centavos).to eq(2250)
  end

  it "usa a tarifa vigente" do
    Tarifa.create!(valor_centavos: 600)

    expect(Recarga.new(user:, quantidade: 5, metodo_pagamento: "pix").tap(&:validate).valor_centavos).to eq(3000)
  end

  it "exige ao menos uma refeição" do
    recarga = Recarga.new(user:, quantidade: 0, metodo_pagamento: "pix")

    expect(recarga).not_to be_valid
    expect(recarga.errors[:quantidade]).to be_present
  end

  it "aceita apenas PIX ou cartão de crédito" do
    expect(Recarga.new(user:, quantidade: 2, metodo_pagamento: "cartao")).to be_valid
    expect(Recarga.new(user:, quantidade: 2, metodo_pagamento: "boleto")).not_to be_valid
  end

  it "dá o nome de exibição do método de pagamento" do
    expect(Recarga::METODOS_PAGAMENTO).to eq("pix" => "PIX Instantâneo", "cartao" => "Cartão de Crédito")
  end
end
