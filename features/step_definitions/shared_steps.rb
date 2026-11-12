# features/step_definitions/shared_steps.rb
require "pdf-reader"

World(ActiveSupport::Testing::TimeHelpers)

After do
  travel_back
end

def login_as(user)
  page.driver.post("/test_login", user_id: user.id)
end

def extracted_pdf_text
  reader = PDF::Reader.new(StringIO.new(page.body.b))
  reader.pages.map(&:text).join("\n")
end

Dado("que o estudante está autenticado") do
  @student = User.find_or_create_by!(registration_number: "231012345") do |u|
    u.name = "Estudante UnB"
    u.role = "student"
    u.balance = 50.0
  end
  login_as(@student)
end

Dado("que o administrador está autenticado") do
  @admin = User.find_or_create_by!(registration_number: "000111222") do |u|
    u.name = "Administrador RU"
    u.role = "admin"
  end
  login_as(@admin)
end

Dado("que existem acessos registrados nos restaurantes {string} e {string}") do |rest1, rest2|
  student = User.find_or_create_by!(registration_number: "211000111") do |u|
    u.name = "Aluno Teste"
    u.role = "student"
  end

  [rest1, rest2].each do |r_name|
    restaurant = Restaurant.find_or_create_by!(name: r_name)
    turnstile = Turnstile.find_or_create_by!(name: "Catraca Principal #{r_name}", restaurant: restaurant)
    AccessLog.create!(
      user: student,
      restaurant: restaurant,
      turnstile: turnstile,
      meal_type: "almoco",
      amount_paid: 5.20,
      accessed_at: Time.current
    )
  end
end

Então("o sistema deve gerar um arquivo PDF para download") do
  expect(page.response_headers["Content-Type"]).to include("application/pdf")
  expect(page.body.b).to start_with("%PDF-")
end

Então("nenhum arquivo PDF deve ser gerado") do
  expect(page.response_headers["Content-Type"]).to include("text/html")
end