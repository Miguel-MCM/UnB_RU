def operador_padrao_relatorio
  Funcionario.find_or_create_by!(matricula: "999888777") do |f|
    f.nome = "Operador Relatório"
    f.password = "Senha123"
    f.administrador = true
  end
end

Dado("que existem acessos registrados nos restaurantes {string} e {string}") do |rest1, rest2|
  operador = operador_padrao_relatorio

  [ rest1, rest2 ].each do |r_nome|
    restaurante = Restaurante.find_or_create_by!(nome: r_nome)
    catraca = Catraca.find_or_create_by!(nome: "Catraca Principal #{r_nome}", restaurante: restaurante)
    Acesso.create!(
      funcionario: operador,
      restaurante: restaurante,
      catraca: catraca,
      identificacao: "231012345",
      status: :confirmado,
      valor_centavos: 450
    )
  end
end

Dado("que existem acessos registrados em ambas as catracas") do
  operador = operador_padrao_relatorio
  Catraca.find_each do |catraca|
    Acesso.create!(
      funcionario: operador,
      restaurante: catraca.restaurante,
      catraca: catraca,
      identificacao: "231012345",
      status: :confirmado,
      valor_centavos: 450
    )
  end
end

Dado("que o restaurante {string} não possui acessos registrados") do |rest_nome|
  restaurante = Restaurante.find_or_create_by!(nome: rest_nome)
  Acesso.where(restaurante_id: restaurante.id).delete_all
end

Quando("o administrador acessar o relatório global de acessos") do
  visit access_reports_path
end

Quando("o administrador filtrar o relatório pelo restaurante {string}") do |rest_nome|
  visit access_reports_path(restaurante_nome: rest_nome)
end

Quando("o administrador filtrar o relatório pela catraca {string}") do |cat_nome|
  visit access_reports_path(catraca_nome: cat_nome)
end

Quando("o administrador agrupar o relatório por restaurante") do
  visit access_reports_path(group_by: "restaurante")
end

Quando("o administrador agrupar o relatório por catraca") do
  visit access_reports_path(group_by: "catraca")
end

Quando("o administrador filtrar o relatório pelo restaurante {string} e pela catraca {string}") do |rest_nome, cat_nome|
  Restaurante.find_or_create_by!(nome: rest_nome)
  visit access_reports_path(restaurante_nome: rest_nome, catraca_nome: cat_nome)
end

Então("o relatório deve exibir os acessos de todos os restaurantes") do
  expect(page).to have_css("#access-logs-table", text: "Darcy Ribeiro")
  expect(page).to have_css("#access-logs-table", text: "Gama")
end

Então("o relatório deve exibir apenas os acessos do restaurante {string}") do |rest_nome|
  expect(page).to have_css("#access-logs-table", text: rest_nome)
  outro = rest_nome == "Darcy Ribeiro" ? "Gama" : "Darcy Ribeiro"
  expect(page).not_to have_css("#access-logs-table", text: outro)
end

Então("o relatório deve exibir apenas os acessos da catraca {string}") do |cat_nome|
  expect(page).to have_css("#access-logs-table", text: cat_nome)
  outra = cat_nome == "Entrada 1" ? "Entrada 2" : "Entrada 1"
  expect(page).not_to have_css("#access-logs-table", text: outra)
end

Então("o relatório deve exibir o total de acessos de cada restaurante separadamente") do
  expect(page).to have_css("#grouped-summary", text: "Darcy Ribeiro: 1 acessos")
  expect(page).to have_css("#grouped-summary", text: "Gama: 1 acessos")
end

Então("o relatório deve exibir o total de acessos de cada catraca separadamente") do
  expect(page).to have_css("#grouped-summary", text: "Entrada 1: 1 acessos")
  expect(page).to have_css("#grouped-summary", text: "Entrada 2: 1 acessos")
end

Então("o relatório deve informar que não há acessos para o filtro selecionado") do
  expect(page).to have_content("Não há acessos para o filtro selecionado")
end

Então("o relatório deve informar que a catraca {string} não pertence ao restaurante {string}") do |cat_nome, rest_nome|
  expect(page).to have_content("A catraca #{cat_nome} não pertence ao restaurante #{rest_nome}")
end
