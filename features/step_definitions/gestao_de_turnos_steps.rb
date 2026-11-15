module GestaoDeTurnosHelpers
  def cartao_do_turno(nome)
    find(".turno", text: nome) { |cartao| cartao.find(".turno__nome").text == nome }
  end

  def restaurante_chamado(nome)
    Restaurante.find_or_create_by!(nome:)
  end

  def turno_chamado(nome)
    @restaurante.turnos.find_by!(nome:)
  end

  def time_frames_do(turno)
    turno.time_frames.reload.map(&:horario)
  end
end

World(GestaoDeTurnosHelpers)

Dado("que não existe o turno {string} no restaurante {string}") do |turno, restaurante|
  expect(restaurante_chamado(restaurante).turnos.find_by(nome: turno)).to be_nil
end

Dado("que existe o turno {string} das {hora} às {hora} no restaurante {string}") do |turno, inicio, fim, restaurante|
  restaurante_chamado(restaurante).turnos.create!(nome: turno, hora_inicio: inicio, hora_fim: fim)
end

Dado("que o turno {string} das {hora} às {hora} está dividido em time-frames de {int} minutos") do |turno, inicio, fim, minutos|
  turno = @restaurante.turnos.create!(nome: turno, hora_inicio: inicio, hora_fim: fim)
  expect(turno.dividir_em_time_frames!(minutos)).to be(true)
end

Quando("o administrador cadastrar o turno {string} das {hora} às {hora} no restaurante {string}") do |turno, inicio, fim, restaurante|
  visit admin_restaurantes_path
  within(cartao_do_restaurante(restaurante)) { click_link "Turnos" }
  fill_in "Nome do turno", with: turno
  fill_in "Horário de início", with: inicio
  fill_in "Horário de término", with: fim
  click_button "Cadastrar turno"
end

Quando(/^o administrador (?:definir|alterar) a duração dos time-frames do turno "([^"]*)" (?:em|para) (\d+) minutos$/) do |turno, minutos|
  @turno_nome = turno
  turno = turno_chamado(turno)
  @time_frames_antes = time_frames_do(turno)
  @duracao_antes = turno.duracao_time_frame_min

  visit admin_restaurante_turnos_path(@restaurante)
  within(cartao_do_turno(turno.nome)) do
    @time_frames_na_tela_antes = all(".time-frame").map(&:text)
    fill_in "Duração do time-frame (minutos)", with: minutos
    click_button "Dividir em time-frames"
  end
end

Quando(/^um estudante consultar os time-frames do (.+) para inscrição no FastPass$/) do |_turno|
  entrar_como_estudante
  within("nav") { click_link "FastPass" }
end

Então("o turno {string} deve ficar cadastrado das {hora} às {hora} no restaurante {string}") do |turno, inicio, fim, restaurante|
  within(cartao_do_turno(turno)) { expect(page).to have_css(".turno__horario", exact_text: "#{inicio} às #{fim}") }

  cadastrado = Restaurante.find_by!(nome: restaurante).turnos.find_by!(nome: turno)
  expect(cadastrado).to have_attributes(hora_inicio: inicio, hora_fim: fim)
end

Então("o turno {string} deve ser dividido em {int} time-frames") do |turno, quantidade|
  @turno_nome = turno
  within(cartao_do_turno(turno)) { expect(page).to have_css(".time-frame", count: quantidade) }
  expect(turno_chamado(turno).time_frames.count).to eq(quantidade)
end

Então(/^o (primeiro|último) time-frame deve ser das (\d{2}:\d{2}) às (\d{2}:\d{2})$/) do |posicao, inicio, fim|
  within(cartao_do_turno(@turno_nome)) do
    time_frames = all(".time-frame")
    time_frame = posicao == "primeiro" ? time_frames.first : time_frames.last
    expect(time_frame).to have_text(/\A#{inicio} às #{fim}\z/)
  end
end

Então("deve visualizar os {int} time-frames do turno {string}") do |quantidade, turno|
  expect(page).to have_css("h1", text: "FastPass")
  within(cartao_do_turno(turno)) { expect(page).to have_css(".time-frame", count: quantidade) }
end

Então("o turno não deve ser cadastrado") do
  expect(page).to have_no_css(".turno")
  expect(@restaurante.turnos.reload).to be_empty
end

Então("o turno {string} não deve ser cadastrado") do |turno|
  expect(page).to have_no_css(".turno__nome", exact_text: turno)
  expect(@restaurante.turnos.find_by(nome: turno)).to be_nil
end

Então("os time-frames não devem ser alterados") do
  within(cartao_do_turno(@turno_nome)) do
    if @time_frames_na_tela_antes.empty?
      expect(page).to have_no_css(".time-frame")
      expect(page).to have_text("Turno ainda não dividido em time-frames.")
    else
      expect(all(".time-frame").map(&:text)).to eq(@time_frames_na_tela_antes)
    end
  end

  turno = turno_chamado(@turno_nome)
  expect(time_frames_do(turno)).to eq(@time_frames_antes)
  expect(turno.reload.duracao_time_frame_min).to eq(@duracao_antes)
end

Então("deve informar que o horário de término deve ser posterior ao de início") do
  expect(page).to have_css(".flash--alert", text: "O horário de término deve ser posterior ao de início")
end

Então("deve informar que o horário conflita com o turno {string}") do |turno|
  expect(page).to have_css(".flash--alert", text: "O horário conflita com o turno #{turno}")
end

Então("deve informar que a duração do time-frame não pode ser maior que a duração do turno") do
  expect(page).to have_css(".flash--alert", text: "A duração do time-frame não pode ser maior que a duração do turno")
end
