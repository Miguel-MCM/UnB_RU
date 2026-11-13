require "rails_helper"

RSpec.describe Menu, type: :model do
  describe ".current_meal_type" do
    it "retorna cafe_da_manha às 08:00 (caminho feliz)" do
      expect(Menu.current_meal_type(Time.zone.local(2026, 11, 9, 8, 0))).to eq("cafe_da_manha")
    end

    it "retorna almoco às 12:30 (caminho feliz)" do
      expect(Menu.current_meal_type(Time.zone.local(2026, 11, 9, 12, 30))).to eq("almoco")
    end

    it "retorna jantar às 18:15 (caminho feliz)" do
      expect(Menu.current_meal_type(Time.zone.local(2026, 11, 9, 18, 15))).to eq("jantar")
    end

    it "retorna nil fora do horário de refeição às 15:30 e às 22:00 (caminhos tristes)" do
      expect(Menu.current_meal_type(Time.zone.local(2026, 11, 9, 15, 30))).to be_nil
      expect(Menu.current_meal_type(Time.zone.local(2026, 11, 9, 22, 0))).to be_nil
    end
  end

  describe "validações" do
    it "é inválido com tipo de refeição desconhecido (caminho triste)" do
      menu = Menu.new(
        served_on: Date.current,
        meal_type: "lanche_da_madrugada",
        standard_dish: "Pão",
        ovolacto_dish: "Queijo",
        vegan_dish: "Fruta"
      )
      expect(menu).not_to be_valid
    end
  end
end
