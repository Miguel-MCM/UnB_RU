Dado('que o funcionário acessou a página de "Autenticação do Operador"') do
  @funcionario = Funcionario.create!(nome: "Carlos Mendes", matricula: "1984201", password: "Operador123")

  visit operador_login_path
  expect(page).to have_css("h1", text: "Autenticação do Operador")
end

Dado("preenche o campo {string} com uma senha válida") do |campo|
  fill_in campo, with: @funcionario.password
end

Então("a sessão do operador deve ser autenticada com sucesso") do
  expect(page).to have_current_path(operador_terminal_path)
  expect(page).to have_text(@funcionario.nome)
end

Então("o sistema deve liberar o terminal de catraca para operação") do
  expect(page).to have_text("Terminal liberado para operação")
end

Dado("que o funcionário deixa os campos de credenciais em branco") do
  fill_in "Matrícula SIAPE ou Usuário SIGAA / gov.br", with: ""
  fill_in "Senha de Acesso", with: ""
end

Então("o sistema deve exibir mensagens de campo obrigatório") do
  expect(page).to have_css(".field__error", text: "Campo obrigatório", count: 2)
end

Então("a sessão não deve ser iniciada") do
  visit operador_terminal_path
  expect(page).to have_current_path(operador_login_path)
end

Dado("que o formulário de autenticação está visível para o operador") do
  expect(page).to have_button("Entrar no Sistema")
end

Então("os campos {string} e {string} devem ser sinalizados como obrigatórios") do |*campos|
  campos.each do |campo|
    expect(find_field(campo)[:required]).to be_truthy
    within(find(".field", text: campo)) { expect(page).to have_css(".field__hint", text: "Obrigatório") }
  end
end
