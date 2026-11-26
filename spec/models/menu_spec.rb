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

  describe ".meal_label" do
    it "retorna o rótulo em português para tipos válidos (caminho feliz)" do
      expect(Menu.meal_label("cafe_da_manha")).to eq("café da manhã")
      expect(Menu.meal_label("almoco")).to eq("almoço")
      expect(Menu.meal_label("jantar")).to eq("jantar")
    end

    it "retorna nil para tipo desconhecido (caminho triste)" do
      expect(Menu.meal_label("ceia")).to be_nil
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

  describe ".gerar_do_json!" do
    let(:segunda) { Date.new(2026, 11, 9) }

    it "cria os cardápios da semana a partir do cardapio.json" do
      expect(described_class.gerar_do_json!(segunda, dias: 7)).to eq(21)

      cafe = described_class.find_by!(served_on: segunda, meal_type: "cafe_da_manha")
      expect(cafe).to have_attributes(standard_dish: "Carne desfiada", ovolacto_dish: "Queijo muçarela",
                                      vegan_dish: "Homus de grão de bico", extra_option: nil)

      almoco = described_class.find_by!(served_on: segunda, meal_type: "almoco")
      expect(almoco).to have_attributes(standard_dish: "Frango assado com manjericão", salads: "Alface lisa com agrião e Tomate",
                                        side_dishes: "Arroz branco e integral e Feijão preto", beverage: "Refresco de morango")

      jantar = described_class.find_by!(served_on: segunda, meal_type: "jantar")
      expect(jantar).to have_attributes(soup: "Creme de abóbora", has_toast: true, standard_dish: "Lagarto ao molho escuro")
    end

    it "usa o dia da semana da data (terça recebe o cardápio de terça)" do
      described_class.gerar_do_json!(segunda + 1, dias: 1)

      expect(described_class.where(served_on: segunda + 1).count).to eq(3)
      expect(described_class.where(served_on: segunda).count).to eq(0)
    end

    it "não altera cardápios já existentes (edições são preservadas)" do
      editado = described_class.create!(served_on: segunda, meal_type: "almoco", standard_dish: "Feijoada",
                                        ovolacto_dish: "Omelete", vegan_dish: "Tofu")

      expect(described_class.gerar_do_json!(segunda, dias: 1)).to eq(2)
      expect(editado.reload.standard_dish).to eq("Feijoada")
      expect(described_class.gerar_do_json!(segunda, dias: 1)).to eq(0)
    end

    it "não cria nada sem o arquivo ou para um dia ausente dele" do
      expect(described_class.gerar_do_json!(segunda, arquivo: Rails.root.join("tmp/nao_existe.json"))).to eq(0)

      arquivo = Tempfile.new([ "cardapio", ".json" ])
      arquivo.write({ "terca-feira" => { "almoco" => {}, "ceia" => { "x" => "y" } } }.to_json)
      arquivo.flush
      expect(described_class.gerar_do_json!(segunda, dias: 1, arquivo: Pathname(arquivo.path))).to eq(0)
    ensure
      arquivo&.close!
    end
  end

  describe ".do_dia" do
    let(:segunda) { Date.new(2026, 11, 9) }

    it "devolve nil sem registro quando a geração automática está desligada" do
      expect(described_class.do_dia(segunda, "almoco")).to be_nil
      expect(described_class.count).to eq(0)
    end

    it "gera o cardápio do dia a partir do arquivo quando a geração está ligada" do
      allow(Rails.configuration.x.cardapio).to receive(:gerar_do_json).and_return(true)

      menu = described_class.do_dia(segunda, "almoco")

      expect(menu.standard_dish).to eq("Frango assado com manjericão")
      expect(described_class.where(served_on: segunda).count).to eq(3)
    end

    it "devolve o registro existente sem consultar o arquivo" do
      existente = described_class.create!(served_on: segunda, meal_type: "almoco", standard_dish: "A", ovolacto_dish: "B", vegan_dish: "C")
      allow(Rails.configuration.x.cardapio).to receive(:gerar_do_json).and_return(true)

      expect(described_class.do_dia(segunda, "almoco")).to eq(existente)
      expect(described_class.count).to eq(1)
    end
  end
end
