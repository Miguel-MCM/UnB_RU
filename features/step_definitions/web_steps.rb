Dado(/^(?:que o estudante )?preenche o campo "([^"]*)" com "([^"]*)"$/) do |campo, valor|
  fill_in campo, with: valor
end

Quando("clica no botão {string}") do |botao|
  click_button botao
end

Quando("clica no link {string}") do |link|
  click_link link
end
