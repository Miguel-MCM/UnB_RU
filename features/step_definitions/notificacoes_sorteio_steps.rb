module NotificacoesSorteioHelpers
  def momento_do_cenario(hora)
    data = (@data_do_cenario ||= Date.current)
    horas, minutos = hora.split(":").map(&:to_i)
    Time.zone.local(data.year, data.month, data.day, horas, minutos)
  end

  def notificacoes_do(matricula)
    User.find_by!(matricula:).notificacoes.reload
  end

  def abrir_notificacoes_como(matricula)
    @estudante = User.find_by!(matricula:)
    entrar_como_estudante
    within("nav") { click_link "Notificações" }
  end
end

World(NotificacoesSorteioHelpers)

Dado("que o turno {string} do restaurante {string} começa às {hora}") do |turno, restaurante, hora|
  @restaurante = restaurante_chamado(restaurante)
  @data_do_cenario ||= Date.current
  expect(turno_do_fastpass(turno).hora_inicio).to eq(hora)
end

Dado(/^que o estudante "(\d+)" não está inscrito no FastPass do (\S+)$/) do |matricula, turno|
  estudante = estudante_do_fastpass(matricula)
  expect(estudante.inscricoes_fastpass.do_dia(@data_do_cenario || Date.current).do_turno(turno_chamado(turno))).to be_empty
end

Dado(/^que o estudante "(\d+)" já recebeu a notificação do sorteio do (\S+)$/) do |matricula, _turno|
  Sorteio.notificar_pendentes!(momento_do_cenario("10:00"))
  @notificacoes_antes = notificacoes_do(matricula).count
  expect(@notificacoes_antes).to eq(1)
end

Quando("o horário atual for {hora}") do |hora|
  travel_to momento_do_cenario(hora)
  Sorteio.notificar_pendentes!
end

Então(/^o estudante "(\d+)" deve receber uma notificação informando que (não )?ganhou o FastPass$/) do |matricula, nao|
  abrir_notificacoes_como(matricula)

  tipo = nao ? "nao_contemplado" : "contemplado"
  texto = nao ? "Você não ganhou o FastPass do almoço" : "Você ganhou o FastPass do almoço"
  expect(page).to have_css(".notificacao--#{tipo}", text: texto)

  notificacoes = notificacoes_do(matricula)
  expect(notificacoes.count).to eq(1)
  expect(notificacoes.first.tipo).to eq(tipo)
end

Então("a notificação deve informar o time-frame das {hora} às {hora}") do |inicio, fim|
  expect(page).to have_css(".notificacao__mensagem", text: "das #{inicio} às #{fim}")
  expect(@estudante.notificacoes.reload.first.mensagem).to include("das #{inicio} às #{fim}")
end

Então(/^o estudante "(\d+)" não deve (?:ter recebido|receber) notificação do sorteio do (\S+)$/) do |matricula, _turno|
  abrir_notificacoes_como(matricula)

  expect(page).to have_no_css(".notificacao")
  expect(page).to have_content("Você não tem notificações.")
  expect(notificacoes_do(matricula)).to be_empty
end

Então(/^o estudante "(\d+)" não deve receber uma nova notificação do sorteio do (\S+)$/) do |matricula, _turno|
  expect(notificacoes_do(matricula).count).to eq(@notificacoes_antes)

  abrir_notificacoes_como(matricula)
  expect(page).to have_css(".notificacao", count: 1)
end
