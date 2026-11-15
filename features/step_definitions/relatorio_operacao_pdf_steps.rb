require "pdf-reader"

def texto_extraido_do_pdf
  reader = PDF::Reader.new(StringIO.new(page.body.b))
  reader.pages.map(&:text).join("\n")
end

Dado("que o relatório está filtrado pelo restaurante {string}") do |rest_nome|
  @restaurante_filtrado_pdf = rest_nome
end

Dado("que não existem acessos registrados") do
  Acesso.delete_all
end

Quando("o administrador exportar o relatório global de operação em PDF") do
  params = @restaurante_filtrado_pdf ? { restaurante_nome: @restaurante_filtrado_pdf } : {}
  visit export_pdf_access_reports_path(params)
end

unless system("grep -rn 'o sistema deve gerar um arquivo PDF para download' features/step_definitions/ --exclude='relatorio_operacao_pdf_steps.rb' > /dev/null 2>&1")
  Então("o sistema deve gerar um arquivo PDF para download") do
    expect(page.response_headers["Content-Type"]).to include("application/pdf")
    expect(page.body.b).to start_with("%PDF-")
  end

  Então("nenhum arquivo PDF deve ser gerado") do
    expect(page.response_headers["Content-Type"]).to include("text/html")
  end
end

Então("o PDF deve conter os acessos de todos os restaurantes") do
  texto = texto_extraido_do_pdf
  expect(texto).to include("Darcy Ribeiro")
  expect(texto).to include("Gama")
end

Então("o PDF deve conter apenas os acessos do restaurante {string}") do |rest_nome|
  texto = texto_extraido_do_pdf
  expect(texto).to include(rest_nome)
  outro = rest_nome == "Darcy Ribeiro" ? "Gama" : "Darcy Ribeiro"
  expect(texto).not_to include(outro)
end

Então("o sistema deve informar que não há dados para exportar") do
  expect(page).to have_content("Não há dados para exportar")
end
