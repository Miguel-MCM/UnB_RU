module ExtratoHelpers
  def operador_do_extrato
    @operador_do_extrato ||= Funcionario.create!(nome: "Carlos Mendes", matricula: "1984201", password: "Operador123")
  end

  def refeicao!(refeicao, em:, valor_centavos: 450)
    Acesso.create!(user: @estudante, funcionario: operador_do_extrato, identificacao: @estudante.matricula,
                   status: "confirmado", refeicao:, valor_centavos:, created_at: em)
  end

  def recarga!(quantidade, em:)
    Recarga.create!(user: @estudante, quantidade:, metodo_pagamento: "pix", created_at: em)
  end

  def indicador(titulo)
    find(".indicador", text: titulo)
  end

  def reais(centavos)
    ActiveSupport::NumberHelper.number_to_currency(centavos / 100.0)
  end
end

World(ExtratoHelpers)

Dado("que o estudante possui registros financeiros e de acesso no período atual") do
  travel_to Time.zone.local(2024, 5, 14, 15, 0)

  refeicao!("almoco", em: 2.days.ago)
  refeicao!("almoco", em: 1.day.ago)
  refeicao!("jantar", em: 1.day.ago)
  recarga!(10, em: 10.days.ago)
  recarga!(10, em: 3.days.ago)

  refeicao!("almoco", em: 1.month.ago)
  recarga!(20, em: 1.month.ago)
end

Quando("visualiza o topo da página de extrato") do
  visit statements_path
end

Então("o sistema deve exibir o {string} com o valor correspondente") do |titulo|
  within(indicador(titulo)) do
    expect(page).to have_text(reais(3 * 450))
    expect(page).to have_text("3 débitos de #{reais(450)}")
  end
end

Então("deve exibir o total de {string} detalhando a frequência") do |titulo|
  within(indicador(titulo)) do
    expect(page).to have_css(".indicador__valor", text: "3")
    expect(page).to have_text("2 almoços · 1 jantar")
  end
end

Então("deve exibir o {string} junto com o saldo restante atual") do |titulo|
  within(indicador(titulo)) do
    expect(page).to have_text(reais(2 * 10 * 450))
    expect(page).to have_text("Saldo restante: #{reais(@estudante.reload.saldo_centavos)}")
  end
end

Dado("que o estudante visualiza a tabela de lançamentos contábeis e registros de catraca") do
  travel_to Time.zone.local(2024, 5, 20, 15, 0)

  refeicao!("almoco", em: Time.zone.local(2024, 5, 10, 12, 20))
  refeicao!("jantar", em: Time.zone.local(2024, 5, 12, 19, 10))
  refeicao!("almoco", em: Time.zone.local(2024, 4, 10, 12, 40))
  recarga!(10, em: Time.zone.local(2024, 5, 5, 9, 0))

  visit statements_path
  expect(page).to have_css("#lancamentos")
end

Quando("aplica o filtro de período de referência para {string}") do |periodo|
  select periodo, from: "Período de referência"
end

Quando("seleciona o tipo de refeição desejado") do
  select "Almoço", from: "Tipo de refeição"
  click_button "Aplicar filtros"
end

Então("a listagem de lançamentos deve ser atualizada de acordo com os filtros selecionados") do
  within("#lancamentos tbody") do
    expect(page).to have_css("tr", count: 1)
    expect(page).to have_text("10/05/2024")
    expect(page).to have_text("Almoço")
    expect(page).to have_no_text("Jantar")
    expect(page).to have_no_text("Recarga")
    expect(page).to have_no_text("10/04/2024")
  end
end

Dado("que o estudante está visualizando o extrato e histórico de refeições") do
  refeicao!("almoco", em: 1.hour.ago)
  visit statements_path
  expect(page).to have_css("h1", text: "Extrato e Histórico de Refeições")
end

Quando("clica no botão {string} ou no botão {string}") do |exportar, imprimir|
  expect(page).to have_button(imprimir)
  click_on exportar
end

Então("o sistema deve gerar o documento correspondente para download ou impressão") do
  expect(page.response_headers["Content-Type"]).to include("application/pdf")
  expect(page.response_headers["Content-Disposition"]).to include("attachment")
  expect(extracted_pdf_text).to include("Extrato e Histórico de Refeições", @estudante.nome)
end
