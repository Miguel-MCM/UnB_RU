require "rails_helper"

RSpec.describe "Cardápio da Refeição Atual (Issue #15)", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let!(:student) do
    User.create!(
      nome: "Ana Beatriz Silva",
      matricula: "221045999",
      password: "password123",
      saldo_centavos: 1800
    )
  end

  before do
    post login_path, params: { matricula: student.matricula, password: "password123" }
  end

  after { travel_back }

  it "exibe o cardápio completo do almoço e os dados do portal do estudante (caminho feliz)" do
    travel_to Time.zone.local(2026, 11, 9, 12, 0, 0)
    Menu.create!(
      served_on: Date.current,
      meal_type: "almoco",
      salads: "Alface",
      garnish: "Farofa",
      side_dishes: "Arroz e feijão",
      standard_dish: "Frango assado com manjericão",
      ovolacto_dish: "Quiche de legumes e lentilha gratinada",
      vegan_dish: "Refogado de lentilha, couve-flor e brócolis",
      dessert: "Maçã",
      beverage: "Suco"
    )

    get current_menu_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Ana Beatriz Silva")
    expect(response.body).to include("Frango assado com manjericão")
    expect(response.body).to include("Quiche de legumes e lentilha gratinada")
    expect(response.body).to include("Refogado de lentilha, couve-flor e brócolis")
  end

  it "informa quando não há refeição sendo servida no momento (caminho triste)" do
    travel_to Time.zone.local(2026, 11, 9, 16, 0, 0)
    get current_menu_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Não há refeição sendo servida no momento")
  end

  it "informa quando o cardápio do turno atual não foi cadastrado (caminho triste)" do
    travel_to Time.zone.local(2026, 11, 9, 12, 0, 0)
    get current_menu_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("O cardápio do almoço não está disponível")
  end

  it "redireciona para login quando o estudante não está autenticado (caminho triste)" do
    delete logout_path
    get current_menu_path

    expect(response).to redirect_to(login_path)
  end
end
