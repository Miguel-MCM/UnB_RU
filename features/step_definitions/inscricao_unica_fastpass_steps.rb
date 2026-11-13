module InscricaoFastpassHelpers
  HORARIOS_TURNO = { "almoço" => %w[11:00 14:00], "jantar" => %w[17:00 20:00] }.freeze

  def time_frame_do(turno, inicio, fim)
    turno_chamado(turno).time_frames.find_by!(
      hora_inicio_min: HorarioEmMinutos.em_minutos(inicio),
      hora_fim_min: HorarioEmMinutos.em_minutos(fim)
    )
  end

  def item_do_time_frame(turno, inicio, fim)
    cartao_do_turno(turno).find(".time-frame", text: "#{inicio} às #{fim}")
  end

  def inscrever_pela_tela(turno, inicio, fim)
    visit fastpass_path
    within(item_do_time_frame(turno, inicio, fim)) { click_button "Inscrever-se" }
  end

  def inscricoes_do_estudante
    @estudante.inscricoes_fastpass.reload
  end

  def sorteio_do(turno)
    turno_chamado(turno).sorteios.find_by!(data_refeicao: Date.current)
  end
end

World(InscricaoFastpassHelpers)

Dado("que o estudante {string} está autenticado") do |matricula|
  @estudante = User.create!(nome: "Mariana Souza Silva", matricula:, password: "Senha123")
  entrar_como_estudante
end

Dado("que o turno {string} do restaurante {string} está dividido em time-frames de {int} minutos") do |turno, restaurante, minutos|
  @restaurante = restaurante_chamado(restaurante)
  inicio, fim = InscricaoFastpassHelpers::HORARIOS_TURNO.fetch(turno)
  turno = @restaurante.turnos.find_or_create_by!(nome: turno) do |novo|
    novo.hora_inicio = inicio
    novo.hora_fim = fim
  end
  expect(turno.dividir_em_time_frames!(minutos)).to be(true)
end

Dado("que as inscrições para o sorteio do FastPass estão abertas") do
  @restaurante.turnos.each do |turno|
    expect(Sorteio.do_dia!(turno)).to be_aberto
  end
end

Dado("que as inscrições para o sorteio do FastPass do {word} foram encerradas") do |turno|
  Sorteio.do_dia!(turno_chamado(turno)).encerrar!
end

Dado("que o estudante possui saldo de {reais}") do |centavos|
  @estudante.update!(saldo_centavos: centavos)
  @saldo_inicial = centavos
end

Dado("que o estudante não está inscrito no FastPass do {word}") do |turno|
  expect(inscricoes_do_estudante.do_dia.do_turno(turno_chamado(turno))).to be_empty
end

Dado(/^que o estudante(?: "(\d+)")? está inscrito no time-frame das (\d{2}:\d{2}) às (\d{2}:\d{2}) do (\S+)$/) do |matricula, inicio, fim, turno|
  estudante = if matricula
    User.find_or_create_by!(matricula:) do |novo|
      novo.nome = "Mariana Souza Silva"
      novo.password = "Senha123"
    end
  else
    @estudante
  end
  inscricao = InscricaoFastpass.inscrever!(user: estudante, time_frame: time_frame_do(turno, inicio, fim))
  expect(inscricao).to be_persisted
end

Quando("o estudante (tentar )se inscrever no time-frame das {hora} às {hora} do {word}") do |inicio, fim, turno|
  @ultimo_time_frame = [ turno, inicio, fim ]
  inscrever_pela_tela(turno, inicio, fim)
end

Então("a inscrição do estudante no time-frame das {hora} às {hora} do {word} deve ser registrada") do |inicio, fim, turno|
  expect(page).to have_css(".flash--notice", text: "Inscrição realizada")
  within(item_do_time_frame(turno, inicio, fim)) { expect(page).to have_css(".time-frame__inscrito", text: "Inscrito") }

  inscricao = inscricoes_do_estudante.find_by(time_frame: time_frame_do(turno, inicio, fim))
  expect(inscricao).to be_inscrito
end

Então("o estudante deve participar do sorteio do FastPass do {word}") do |turno|
  within(cartao_do_turno(turno)) do
    expect(page).to have_css(".turno__inscricao", text: "Você está participando do sorteio do FastPass deste turno.")
  end

  sorteio = sorteio_do(turno)
  expect(sorteio).to be_aberto
  expect(sorteio.inscricoes.inscrito.where(user: @estudante)).to exist
end

Então(/^(?:o estudante )?deve (?:estar|continuar) inscrito (apenas )?no time-frame das (\d{2}:\d{2}) às (\d{2}:\d{2}) do (\S+)$/) do |apenas, inicio, fim, turno|
  # Mantém a página atual (e o flash) quando já está no FastPass.
  visit fastpass_path unless page.current_path == fastpass_path
  within(item_do_time_frame(turno, inicio, fim)) { expect(page).to have_css(".time-frame__inscrito", text: "Inscrito") }

  inscricoes = sorteio_do(turno).inscricoes.where(user: @estudante)
  expect(inscricoes.map(&:time_frame)).to include(time_frame_do(turno, inicio, fim))

  if apenas
    within(cartao_do_turno(turno)) { expect(page).to have_css(".time-frame__inscrito", count: 1) }
    expect(inscricoes.count).to eq(1)
  end
end

Então("a segunda inscrição não deve ser registrada") do
  turno, inicio, fim = @ultimo_time_frame
  expect(sorteio_do(turno).inscricoes.where(user: @estudante).count).to eq(1)
  expect(inscricoes_do_estudante.where(time_frame: time_frame_do(turno, inicio, fim))).to be_empty
  within(item_do_time_frame(turno, inicio, fim)) { expect(page).to have_no_css(".time-frame__inscrito") }
end

Então("a inscrição não deve ser registrada") do
  expect(page).to have_no_css(".time-frame__inscrito")
  expect(inscricoes_do_estudante).to be_empty
end

Então("deve informar que só é permitido um time-frame por turno") do
  expect(page).to have_css(".flash--alert", text: "Só é permitido um time-frame por turno")
end

Então("deve informar que as inscrições para o turno estão encerradas") do
  expect(page).to have_css(".flash--alert", text: "As inscrições para o turno estão encerradas")
end
