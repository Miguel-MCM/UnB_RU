Dado("que o funcionário está autenticado na Aplicação de Controle") do
  entrar_como_funcionario
end

Dado("que os restaurantes {string} e {string} estão disponíveis") do |*nomes|
  nomes.each { |nome| Restaurante.find_or_create_by!(nome:) }
end

Dado("que o restaurante {string} está disponível") do |nome|
  Restaurante.find_or_create_by!(nome:)
end

Quando("o login for concluído") do
  entrar_como_funcionario
end

Então(/^(?:o sistema )?deve solicitar a seleção do restaurante$/) do
  expect(page).to have_current_path(operador_ponto_de_acesso_path)
  expect(page).to have_css("h1", text: "Selecione o restaurante")
end

Então(/^deve exibir os restaurantes (.+) e (.+)$/) do |*nomes|
  within("#restaurantes") do
    nomes.each { |nome| expect(page).to have_button(nome) }
  end
end

Quando("o funcionário selecionar o restaurante {string}") do |nome|
  selecionar_restaurante(nome)
end

Então("o ponto de acesso deve ficar configurado para o restaurante {string}") do |nome|
  expect(page).to have_current_path(operador_terminal_path)
  expect(page).to have_css("#ponto-de-acesso", text: nome)
end

Então("as operações seguintes devem usar as regras do restaurante {string}") do |nome|
  visit operador_terminal_path
  expect(page).to have_current_path(operador_terminal_path)
  expect(page).to have_css("#ponto-de-acesso", text: nome)
end

Dado("que o funcionário ainda não selecionou um restaurante") do
  Restaurante.find_or_create_by!(nome: "Darcy Ribeiro")
  @acessos_antes = Acesso.count
end

Quando("tentar iniciar uma operação de controle de acesso") do
  visit operador_terminal_path
end

Então("o sistema não deve iniciar a operação") do
  expect(Acesso.count).to eq(@acessos_antes)
  expect(page).to have_no_field("Identificação do estudante")
  expect(page).to have_text("Selecione o restaurante antes de iniciar a operação.")
end

Dado("que o funcionário selecionou o restaurante {string}") do |nome|
  Restaurante.find_or_create_by!(nome: "Gama")
  configurar_ponto_de_acesso(nome)
end

Dado("que o ponto de acesso está configurado para o restaurante {string}") do |nome|
  configurar_ponto_de_acesso(nome)
end

Quando("uma operação de controle de acesso for registrada") do
  User.find_or_create_by!(matricula: "100001") do |user|
    user.nome = "Mariana Souza Silva"
    user.password = "Senha123"
    user.saldo_centavos = 1000
  end

  visit operador_terminal_path
  fill_in "Identificação do estudante", with: "100001"
  click_button "Ler identificação"
end

Então("o registro da operação deve estar associado ao restaurante {string}") do |nome|
  expect(Acesso.last.restaurante&.nome).to eq(nome)
end

Então("não deve estar associado a outro restaurante") do
  restaurante = Acesso.last.restaurante
  expect(Acesso.where.not(restaurante_id: restaurante.id).or(Acesso.where(restaurante_id: nil))).to be_empty
end
