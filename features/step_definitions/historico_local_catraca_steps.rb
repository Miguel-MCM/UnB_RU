Dado("que o funcionário está autenticado") do
  entrar_como_funcionario unless @funcionario
end

Dado("está gerenciando a catraca {string}") do |nome_catraca|
  restaurante = Restaurante.first || Restaurante.create!(nome: "Darcy Ribeiro")
  @catraca = Catraca.find_or_create_by!(nome: nome_catraca) do |c|
    c.restaurante = restaurante
  end

  visit operador_historico_path(catraca_id: @catraca.id)
end

Dado("que os seguintes acessos foram registrados:") do |table|
  restaurante = Restaurante.first || Restaurante.create!(nome: "Darcy Ribeiro")
  tarifa = Tarifa.vigente_centavos

  table.hashes.each do |row|
    catraca = Catraca.find_or_create_by!(nome: row["catraca"]) do |c|
      c.restaurante = restaurante
    end

    user = User.find_or_create_by!(matricula: row["estudante"]) do |u|
      u.nome = "Estudante #{row['estudante']}"
      u.password = "Senha123"
      u.saldo_centavos = 2000
    end

    Acesso.create!(
      catraca:,
      user:,
      funcionario: @funcionario || Funcionario.first,
      identificacao: row["estudante"],
      status: :confirmado,
      valor_centavos: tarifa
    )
  end
end

Quando("o funcionário consultar o histórico local") do
  visit operador_historico_path
end

Então("o histórico deve exibir os acessos dos estudantes:") do |table|
  within("#historico") do
    table.hashes.each do |row|
      expect(page).to have_content(row["estudante"])
    end
  end
end

Então("o histórico deve exibir o acesso do estudante {string}") do |matricula|
  within("#historico") do
    expect(page).to have_content(matricula)
  end
end

Então("não deve exibir o acesso do estudante {string}") do |matricula|
  within("#historico") do
    expect(page).to have_no_content(matricula)
  end
end

Dado("que não há acessos registrados na catraca {string}") do |nome_catraca|
  catraca = Catraca.find_by(nome: nome_catraca)
  catraca&.acessos&.destroy_all
end

Então("o histórico deve ser exibido vazio") do
  within("#historico") do
    expect(page).to have_css(".painel__vazio")
    expect(page).to have_no_css("tbody tr")
  end
end
