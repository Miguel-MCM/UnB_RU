# features/step_definitions/shared_steps.rb
require "pdf-reader"

World(ActiveSupport::Testing::TimeHelpers)

After do
  travel_back
end

def extracted_pdf_text
  reader = PDF::Reader.new(StringIO.new(page.body.b))
  reader.pages.map(&:text).join("\n")
end

# O login do administrador ("que o administrador está autenticado") fica em
# gestao_restaurantes_catracas_steps.rb e usa o helper entrar_como_funcionario.
Dado("que o estudante está autenticado") do
  @estudante = User.find_or_create_by!(matricula: "231012345") do |user|
    user.nome = "Estudante UnB"
    user.password = "Senha123"
    user.saldo_centavos = 5000
  end

  visit login_path
  fill_in "Matrícula SIGAA ou SIAPE", with: @estudante.matricula
  fill_in "Senha de Acesso", with: "Senha123"
  click_button "Entrar no Sistema"
end

Então("o sistema deve gerar um arquivo PDF para download") do
  expect(page.response_headers["Content-Type"]).to include("application/pdf")
  expect(page.body.b).to start_with("%PDF-")
end

Então("nenhum arquivo PDF deve ser gerado") do
  expect(page.response_headers["Content-Type"]).to include("text/html")
end
