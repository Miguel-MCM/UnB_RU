module GestaoRestaurantesHelpers
  def cartao_do_restaurante(nome)
    find(".unidade", text: nome) { |cartao| cartao.find(".unidade__nome").text == nome }
  end

  def linha_da_catraca(nome)
    find(".catraca", text: nome) { |linha| linha.find(".catraca__nome").text == nome }
  end

  def disponiveis_para_selecao
    { restaurantes: Restaurante.pluck(:nome), catracas: Catraca.pluck(:nome) }
  end
end

World(GestaoRestaurantesHelpers)

Dado("que o administrador está autenticado") do
  entrar_como_funcionario(administrador: true)
end

Dado("que não existe um restaurante chamado {string}") do |nome|
  expect(Restaurante.find_by(nome:)).to be_nil
end

Dado("que existe o restaurante {string}") do |nome|
  @restaurante = Restaurante.find_or_create_by!(nome:)
end

Dado("que existem os restaurantes Darcy Ribeiro e Gama") do
  Restaurante.create!(nome: "Darcy Ribeiro")
  Restaurante.create!(nome: "Gama")
end

Dado("que não existe a catraca {string}") do |nome|
  expect(Catraca.find_by(nome:)).to be_nil
end

Dado("que a catraca {string} está associada ao restaurante {string}") do |catraca, restaurante|
  @catraca = Restaurante.find_or_create_by!(nome: restaurante).catracas.create!(nome: catraca)
end

Dado("que as catracas {string} e {string} estão associadas ao restaurante {string}") do |primeira, segunda, restaurante|
  restaurante = Restaurante.find_or_create_by!(nome: restaurante)
  restaurante.catracas.create!(nome: primeira)
  restaurante.catracas.create!(nome: segunda)
end

Quando("o administrador cadastrar o restaurante {string}") do |nome|
  visit admin_restaurantes_path
  click_link "Cadastrar Restaurante"
  fill_in "Nome do restaurante", with: nome
  click_button "Salvar restaurante"
end

Quando("o administrador alterar o nome do restaurante para {string}") do |nome|
  visit admin_restaurantes_path
  within(cartao_do_restaurante(@restaurante.nome)) { click_link "Editar unidade" }
  fill_in "Nome do restaurante", with: nome
  click_button "Salvar restaurante"
end

Quando("o administrador remover o restaurante {string}") do |nome|
  visit admin_restaurantes_path
  within(cartao_do_restaurante(nome)) { click_button "Remover unidade" }
end

Quando("o administrador cadastrar a catraca {string} no restaurante {string}") do |catraca, restaurante|
  @catraca_nome = catraca
  visit admin_restaurantes_path
  within(cartao_do_restaurante(restaurante)) do
    fill_in "Nova catraca", with: catraca
    click_button "Adicionar catraca"
  end
end

Quando("o administrador alterar o nome da catraca para {string}") do |nome|
  visit admin_restaurantes_path
  within(linha_da_catraca(@catraca.nome)) { click_link "Editar" }
  fill_in "Nome da catraca", with: nome
  click_button "Salvar catraca"
end

Quando("o administrador remover a catraca {string}") do |nome|
  visit admin_restaurantes_path
  within(linha_da_catraca(nome)) { click_button "Remover" }
end

Então(/^o restaurante "([^"]*)" deve (?:ficar|continuar) disponível para seleção(?: na Aplicação de Controle)?$/) do |nome|
  expect(page).to have_css(".unidade__nome", exact_text: nome)
  expect(disponiveis_para_selecao[:restaurantes]).to include(nome)
end

Então("o restaurante {string} não deve mais ficar disponível para seleção") do |nome|
  expect(page).to have_no_css(".unidade__nome", exact_text: nome)
  expect(disponiveis_para_selecao[:restaurantes]).not_to include(nome)
end

Então("a catraca {string} deve ficar associada ao restaurante {string}") do |catraca, restaurante|
  within(cartao_do_restaurante(restaurante)) { expect(page).to have_css(".catraca__nome", exact_text: catraca) }
  expect(Catraca.find_by!(nome: catraca).restaurante.nome).to eq(restaurante)
end

Então("deve ficar disponível para seleção na Aplicação de Controle") do
  expect(disponiveis_para_selecao[:catracas]).to include(@catraca_nome)
end

Então("a catraca {string} deve continuar disponível para seleção") do |nome|
  expect(page).to have_css(".catraca__nome", exact_text: nome)
  expect(disponiveis_para_selecao[:catracas]).to include(nome)
end

Então("a catraca {string} não deve mais ficar disponível para seleção") do |nome|
  expect(page).to have_no_css(".catraca__nome", exact_text: nome)
  expect(disponiveis_para_selecao[:catracas]).not_to include(nome)
end
