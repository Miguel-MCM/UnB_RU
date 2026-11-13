Dado("que o estudante está autenticado no Portal do Estudante RU UnB") do
  @estudante = User.create!(nome: "Ana Beatriz Silva", matricula: "221045999", password: "Senha123", saldo_centavos: 1800)

  visit login_path
  fill_in "Matrícula SIGAA ou SIAPE", with: @estudante.matricula
  fill_in "Senha de Acesso", with: "Senha123"
  click_button "Entrar no Sistema"
end

Dado('acessou a seção de "Recarga"') do
  within("nav") { click_link "Recarga" }
end

Dado("que o estudante visualiza os pacotes de refeições disponíveis") do
  within("#pacotes") do
    [ "2 Refeições", "5 Refeições", "10 Refeições", "20 Refeições" ].each do |pacote|
      expect(page).to have_link(pacote)
    end
  end
end

Quando("seleciona o pacote de {string} no valor de {string}") do |pacote, valor|
  within("#pacotes") do
    expect(find_link(pacote)).to have_text(valor)
    click_link pacote
  end
end

Quando(/^(?:escolhe|seleciona) o método de pagamento "([^"]*)"$/) do |metodo|
  within("#metodos") { click_link metodo }
end

Então("o resumo da recarga deve exibir {string} com o total de {string}") do |refeicoes, total|
  within("#resumo") do
    expect(page).to have_text(refeicoes)
    expect(page).to have_text(total)
  end
end

Então("o novo saldo estimado deve ser atualizado para {string}") do |saldo|
  within("#resumo") { expect(page).to have_text(saldo) }
end

Dado("que o estudante opta por informar uma quantidade personalizada") do
  expect(page).to have_css("#quantidade-personalizada")
end

Quando("define a quantidade de {string} refeições utilizando os botões de ajuste") do |quantidade|
  alvo = quantidade.to_i

  20.times do
    atual = find("#quantidade-personalizada output").text.to_i
    break if atual == alvo

    click_link(atual < alvo ? "Aumentar quantidade" : "Diminuir quantidade")
  end

  expect(page).to have_css("#quantidade-personalizada output", exact_text: quantidade)
end

Então("o sistema deve calcular automaticamente o valor total de {string} com base na tarifa unitária de {string}") do |total, tarifa|
  @total = total
  within("#quantidade-personalizada") do
    expect(page).to have_text("× #{tarifa}")
    expect(page).to have_text(total)
  end
end

Então("o resumo da recarga deve refletir o valor total correspondente") do
  within("#resumo") { expect(page).to have_text(@total) }
end

Dado("que o estudante selecionou um pacote de recarga") do
  within("#pacotes") { click_link "2 Refeições" }
end

Então("o sistema deve exibir o QR Code para leitura no aplicativo do banco") do
  expect(page).to have_css("#pix svg[aria-label='QR Code PIX']")
end

Então("deve disponibilizar a chave PIX copia e cola com o botão {string}") do |botao|
  within("#pix") do
    expect(find_field("Chave Pix").value).to start_with("000201")
    expect(page).to have_button(botao)
  end
end

Dado("que o estudante configurou a recarga de {string} via {string}") do |pacote, metodo|
  within("#pacotes") { click_link pacote }
  within("#metodos") { click_link metodo }
end

Dado("o resumo da recarga está correto com o total de {string}") do |total|
  within("#resumo") { expect(page).to have_text(total) }
end

Então("a recarga deve ser processada com sucesso") do
  expect(page).to have_text("Recarga confirmada")
end

Então("os créditos devem ser adicionados ao saldo atual da conta") do
  expect(@estudante.reload.saldo_centavos).to eq(1800 + 2250)
  expect(page).to have_text("R$ 40,50")
end
