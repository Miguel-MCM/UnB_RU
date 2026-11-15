Dado("que o valor vigente da refeição é de {reais}") do |centavos|
  Tarifa.create!(valor_centavos: centavos)
end

Dado("que o estudante {string} possui saldo de {reais}") do |matricula, centavos|
  @estudante = User.create!(nome: "Mariana Souza Silva", matricula:, password: "Senha123", saldo_centavos: centavos)
  @saldo_inicial = centavos
end

Dado("que não existe estudante com a identificação {string}") do |matricula|
  expect(User.find_by(matricula:)).to be_nil
end

Quando("a Aplicação de Controle ler a identificação {string}") do |identificacao|
  entrar_como_funcionario unless @funcionario

  visit operador_terminal_path
  fill_in "Identificação do estudante", with: identificacao
  click_button "Ler identificação"
end

Então("deve enviar o comando de liberação para a catraca") do
  expect(page).to have_css("#resultado", text: "Acesso liberado")
  expect(Acesso.last).to be_liberado
end

Então("não deve enviar o comando de liberação para a catraca") do
  expect(page).to have_css("#resultado", text: "Acesso negado")
  expect(Acesso.where(status: %w[liberado confirmado])).to be_empty
end

Então(/^(?:enquanto a passagem não for confirmada, )?o saldo do estudante deve continuar em (R\$ [\d.]+,\d{2})$/) do |valor|
  expect(@estudante.reload.saldo_centavos).to eq(valor.delete("^0-9").to_i)
end

Quando("a passagem do estudante pela catraca for confirmada") do
  click_button "Confirmar passagem"
end

Então("deve debitar {reais} do saldo do estudante") do |centavos|
  expect(page).to have_css("#resultado", text: "Passagem confirmada")
  expect(Acesso.last).to be_confirmado
  expect(Acesso.last.valor_centavos).to eq(centavos)
end

Então("o saldo do estudante deve ser de {reais}") do |centavos|
  expect(@estudante.reload.saldo_centavos).to eq(centavos)
  expect(page).to have_css("#resultado", text: "Saldo restante: #{ActiveSupport::NumberHelper.number_to_currency(centavos / 100.0)}")
end

Então("não deve efetuar débito no saldo do estudante") do
  expect(@estudante.reload.saldo_centavos).to eq(@saldo_inicial)
end

Então("não deve efetuar débito") do
  expect(Acesso.confirmado).to be_empty
end

Então("deve informar que o saldo é insuficiente") do
  expect(page).to have_css("#resultado", text: "Saldo insuficiente")
end

Então("deve informar que o estudante não foi encontrado") do
  expect(page).to have_css("#resultado", text: "Estudante não encontrado")
end
