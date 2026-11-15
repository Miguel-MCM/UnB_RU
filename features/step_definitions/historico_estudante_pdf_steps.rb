def operador_padrao_extrato
  Funcionario.find_or_create_by!(matricula: "888777666") do |f|
    f.nome = "Operador Catraca Extrato"
    f.password = "Senha123"
    f.administrador = false
  end
end

Dado("que o estudante de matrícula {string} está autenticado no Portal do Estudante RU UnB") do |matricula|
  @estudante = User.find_or_create_by!(matricula: matricula) do |u|
    u.nome = "Estudante #{matricula}"
    u.password = "Senha123"
    u.saldo_centavos = 1800
  end

  visit login_path
  fill_in "Matrícula SIGAA ou SIAPE", with: @estudante.matricula
  fill_in "Senha de Acesso", with: "Senha123"
  click_button "Entrar no Sistema"
end

Dado("que o estudante possui recargas e refeições registradas no período atual") do
  @estudante.recargas.create!(quantidade: 5, metodo_pagamento: "pix")
  Acesso.create!(
    user: @estudante,
    funcionario: operador_padrao_extrato,
    identificacao: @estudante.matricula,
    status: :confirmado,
    valor_centavos: 450,
    refeicao: "almoco"
  )
end

Dado("que o estudante filtrou o extrato por período e por tipo de refeição") do
  operador = operador_padrao_extrato
  Acesso.create!(
    user: @estudante,
    funcionario: operador,
    identificacao: @estudante.matricula,
    status: :confirmado,
    valor_centavos: 450,
    refeicao: "almoco"
  )
  Acesso.create!(
    user: @estudante,
    funcionario: operador,
    identificacao: @estudante.matricula,
    status: :confirmado,
    valor_centavos: 450,
    refeicao: "jantar"
  )
  @filtro_extrato_params = { periodo: "mes_atual", tipo: "almoco" }
end

Dado("que existem registros do estudante de matrícula {string}") do |matricula|
  user = User.find_or_create_by!(matricula: matricula) do |u|
    u.nome = "Estudante #{matricula}"
    u.password = "Senha123"
    u.saldo_centavos = 1800
  end
  user.recargas.create!(quantidade: 2, metodo_pagamento: "pix")
  Acesso.create!(
    user: user,
    funcionario: operador_padrao_extrato,
    identificacao: user.matricula,
    status: :confirmado,
    valor_centavos: 450
  )
end

Dado("que o estudante não possui recargas nem refeições registradas") do
  @estudante.recargas.delete_all
  @estudante.acessos.delete_all
end

Quando("o estudante exportar o extrato em PDF") do
  params = @filtro_extrato_params || {}
  visit export_pdf_statements_path(params)
end

Então("o PDF deve conter as recargas e as refeições realizadas") do
  texto = extracted_pdf_text
  expect(texto).to include("Recarga de Saldo")
  expect(texto).to include("Almoço")
end

Então("o PDF deve exibir o total gasto, o total recarregado e o saldo restante") do
  texto = extracted_pdf_text
  expect(texto).to include("Total gasto no mês: R$ 4,50")
  expect(texto).to include("Total recarregado no mês: R$ 22,50")
  expect(texto).to include("Saldo restante: R$ 18,00")
end

Então("o PDF deve conter apenas os lançamentos correspondentes aos filtros selecionados") do
  texto = extracted_pdf_text
  expect(texto).to include("Almoço")
  expect(texto).not_to include("Jantar")
end

Então("o PDF deve conter apenas os registros do estudante de matrícula {string}") do |matricula|
  texto = extracted_pdf_text
  expect(texto).to include(matricula)
  expect(texto).not_to include("222098765")
end

Então("o sistema deve informar que não há registros para exportar") do
  expect(page).to have_content("Não há registros para exportar")
end
