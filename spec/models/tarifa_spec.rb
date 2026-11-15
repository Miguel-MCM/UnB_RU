require "rails_helper"

RSpec.describe Tarifa, type: :model do
  it "vale R$ 4,50 enquanto nenhuma tarifa foi definida" do
    expect(Tarifa.vigente_centavos).to eq(450)
  end

  it "usa a tarifa definida mais recentemente" do
    Tarifa.create!(valor_centavos: 500)
    Tarifa.create!(valor_centavos: 600)

    expect(Tarifa.vigente_centavos).to eq(600)
  end

  it "exige um valor positivo" do
    expect(Tarifa.new(valor_centavos: 0)).not_to be_valid
  end
end
