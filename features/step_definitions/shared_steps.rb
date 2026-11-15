require "pdf-reader"

World(ActiveSupport::Testing::TimeHelpers)

After do
  travel_back
end

def extracted_pdf_text
  reader = PDF::Reader.new(StringIO.new(page.body.b))
  reader.pages.map(&:text).join("\n")
end

Então("o sistema deve gerar um arquivo PDF para download") do
  expect(page.response_headers["Content-Type"]).to include("application/pdf")
  expect(page.body.b).to start_with("%PDF-")
end

Então("nenhum arquivo PDF deve ser gerado") do
  expect(page.response_headers["Content-Type"]).to include("text/html")
end
