# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Operadores não se cadastram pelo site; este é só para testar a aplicação de controle localmente.
if Rails.env.development?
  Funcionario.find_or_create_by!(matricula: "1984201") do |funcionario|
    funcionario.nome = "Carlos Mendes"
    funcionario.password = "Operador123"
  end
end
