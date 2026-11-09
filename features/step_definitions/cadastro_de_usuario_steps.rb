Dado("que o estudante acessou a tela de cadastro de usuário") do
  visit signup_path
end

Dado("que o estudante está visualizando a tela de cadastro de usuário") do
  expect(page).to have_current_path(signup_path)
end

Dado(/^(?:que o estudante )?preenche o campo "([^"]*)" com "([^"]*)"$/) do |campo, valor|
  fill_in campo, with: valor
end

Quando("clica no botão {string}") do |botao|
  click_button botao
end

Quando("clica no link {string}") do |link|
  click_link link
end

Então("o sistema deve criar a conta de acesso com sucesso") do
  expect(User.count).to eq(1)
end

Então("exibir a confirmação de cadastro") do
  expect(page).to have_content("Conta criada com sucesso")
end

Então("o sistema deve exibir uma mensagem de erro informando que as senhas não conferem") do
  expect(page).to have_content("As senhas não conferem")
end

Então("a conta não deve ser criada") do
  expect(User.count).to eq(0)
end

Então("o sistema deve redirecioná-lo para a página de autenticação") do
  expect(page).to have_current_path(login_path)
end
