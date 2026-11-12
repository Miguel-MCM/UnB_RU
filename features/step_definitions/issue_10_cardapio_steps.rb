# features/step_definitions/issue_10_cardapio_steps.rb
def seed_monday_menus(date)
  Menu.create!(
    served_on: date,
    meal_type: "cafe_da_manha",
    standard_dish: "Carne desfiada",
    ovolacto_dish: "Queijo muçarela",
    vegan_dish: "Homus de grão de bico",
    extra_option: nil
  )
  Menu.create!(
    served_on: date,
    meal_type: "almoco",
    salads: "Alface e tomate",
    garnish: "Farofa",
    side_dishes: "Arroz branco, arroz integral e feijão preto",
    standard_dish: "Frango assado com manjericão",
    ovolacto_dish: "Quiche de legumes e lentilha gratinada",
    vegan_dish: "Refogado de lentilha, couve-flor e brócolis",
    dessert: "Melancia",
    beverage: "Refresco de limão"
  )
  Menu.create!(
    served_on: date,
    meal_type: "jantar",
    soup: "Creme de abóbora",
    has_toast: true,
    standard_dish: "Iscas de carne acebolada",
    ovolacto_dish: "Omelete de forno com ervas",
    vegan_dish: "Grão de bico ao curry"
  )
end

Dado("que é segunda-feira e o almoço está sendo servido") do
  travel_to Time.zone.local(2026, 11, 9, 12, 30, 0)
  seed_monday_menus(Date.current)
end

Dado("que é segunda-feira e o café da manhã está sendo servido") do
  travel_to Time.zone.local(2026, 11, 9, 8, 0, 0)
  seed_monday_menus(Date.current)
end

Dado("que é terça-feira e o café da manhã está sendo servido") do
  travel_to Time.zone.local(2026, 11, 10, 8, 0, 0)
  Menu.create!(
    served_on: Date.current,
    meal_type: "cafe_da_manha",
    standard_dish: "Frango desfiado",
    ovolacto_dish: "Queijo minas",
    vegan_dish: "Pasta de berinjela",
    extra_option: "Pão de queijo"
  )
end

Dado("que é segunda-feira e o jantar está sendo servido") do
  travel_to Time.zone.local(2026, 11, 9, 18, 0, 0)
  seed_monday_menus(Date.current)
end

Dado("que nenhuma refeição está sendo servida no momento") do
  travel_to Time.zone.local(2026, 11, 9, 15, 30, 0)
  seed_monday_menus(Date.current)
end

Dado("que o almoço está sendo servido") do
  travel_to Time.zone.local(2026, 11, 9, 12, 30, 0)
end

Dado("que não há cardápio cadastrado para o dia de hoje") do
  Menu.where(served_on: Date.current).delete_all
end

Quando("o estudante acessar o cardápio da refeição atual") do
  visit current_menu_path
end

Então("o sistema deve exibir as saladas, a guarnição, os acompanhamentos, a sobremesa e a bebida do almoço") do
  expect(page).to have_content("Saladas: Alface e tomate")
  expect(page).to have_content("Guarnição: Farofa")
  expect(page).to have_content("Acompanhamentos: Arroz branco, arroz integral e feijão preto")
  expect(page).to have_content("Sobremesa: Melancia")
  expect(page).to have_content("Bebida: Refresco de limão")
end

Então("deve exibir o prato principal de cada opção") do
  expect(page).to have_content("Opção padrão:")
  expect(page).to have_content("Opção ovolactovegetariana:")
  expect(page).to have_content("Opção vegetariana estrita:")
end

Então("o sistema deve exibir a opção {word} com o prato {string}") do |opcao, prato|
  expect(page).to have_content("Opção #{opcao}: #{prato}")
end

Então("o sistema deve exibir a opção vegetariana estrita com o prato {string}") do |prato|
  expect(page).to have_content("Opção vegetariana estrita: #{prato}")
end

Então("o sistema deve exibir o complemento padrão {string}") do |complemento|
  expect(page).to have_content("Complemento padrão: #{complemento}")
end

Então("deve exibir o complemento ovolactovegetariano {string}") do |complemento|
  expect(page).to have_content("Complemento ovolactovegetariano: #{complemento}")
end

Então("deve exibir o complemento vegetariano estrito {string}") do |complemento|
  expect(page).to have_content("Complemento vegetariano estrito: #{complemento}")
end

Então("o sistema deve exibir a opção extra {string}") do |extra|
  expect(page).to have_content("Opção extra: #{extra}")
end

Então("o sistema não deve exibir nenhuma opção extra") do
  expect(page).not_to have_content("Opção extra:")
end

Então("o sistema deve exibir a sopa {string}") do |sopa|
  expect(page).to have_content("Sopa: #{sopa}")
end

Então("deve exibir a torrada") do
  expect(page).to have_content("Torrada")
end

Então("o sistema deve exibir o cardápio do almoço") do
  expect(page).to have_content("Cardápio do almoço")
end

Então("não deve exibir o cardápio do café da manhã nem o do jantar") do
  expect(page).not_to have_content("Cardápio do café da manhã")
  expect(page).not_to have_content("Cardápio do jantar")
end

Então("o sistema deve informar que não há refeição sendo servida no momento") do
  expect(page).to have_content("Não há refeição sendo servida no momento")
end

Então("o sistema deve informar que o cardápio do almoço não está disponível") do
  expect(page).to have_content("O cardápio do almoço não está disponível")
end