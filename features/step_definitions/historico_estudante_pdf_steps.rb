require "pdf-reader"

def texto_pdf_extrato
  reader = PDF::Reader.new(StringIO.new(page.body.b))
  reader.pages.map(&:text).join("\n")
end

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

Dado('acessou a seção de "Extrato"') do
  visit statements_path
end

Dado("que o estudante possui recargas e refeições registradas no período atual") do
  @estudante.recargas.create!(quantidade: 5, metodo_pagamento: "pix")
  Acesso.create!(
    user: @estudante,
    funcionario: operador_padrao_extrato,
    identificacao: @estudante.matricula,
    status: :confirmado,
    valor_centavos: 450,
    created_at: Time.zone.local(2026, 11, 10, 12, 30)
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
    created_at: Time.current.change(hour: 12, min: 15)
  )
  Acesso.create!(
    user: @estudante,
    funcionario: operador,
    identificacao: @estudante.matricula,
    status: :confirmado,
    valor_centavos: 450,
    created_at: Time.current.change(hour: 18, min: 45)
  )
  @filtro_extrato_params = { periodo: "mes_atual", tipo_refeicao: "almoco" }
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

unless system("grep -rn 'o sistema deve gerar um arquivo PDF para download' features/step_definitions/ --exclude='historico_estudante_pdf_steps.rb' > /dev/null 2>&1")
  Então("o sistema deve gerar um arquivo PDF para download") do
    expect(page.response_headers["Content-Type"]).to include("application/pdf")
    expect(page.body.b).to start_with("%PDF-")
  end

  Então("nenhum arquivo PDF deve ser gerado") do
    expect(page.response_headers["Content-Type"]).to include("text/html")
  end
end

Então("o PDF deve conter as recargas e as refeições realizadas") do
  texto = texto_pdf_extrato
  expect(texto).to include("Recarga de Saldo")
  expect(texto).to include("Refeição Realizada")
end

Então("o PDF deve exibir o total gasto, o total recarregado e o saldo restante") do
  texto = texto_pdf_extrato
  expect(texto).to include("Total Gasto: R$ 4,50")
  expect(texto).to include("Total Recarregado: R$ 22,50")
  expect(texto).to include("Saldo Restante: R$ 18,00")
end

Então("o PDF deve conter apenas os lançamentos correspondentes aos filtros selecionados") do
  texto = texto_pdf_extrato
  expect(texto).to include("Almoço")
  expect(texto).not_to include("Jantar")
end

Então("o PDF deve conter apenas os registros do estudante de matrícula {string}") do |matricula|
  texto = texto_pdf_extrato
  expect(texto).to include(matricula)
  expect(texto).not_to include("222098765")
end

Então("o sistema deve informar que não há registros para exportar") do
  expect(page).to have_content("Não há registros para exportar")
end
