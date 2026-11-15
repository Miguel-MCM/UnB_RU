module ValidacaoFastpassHelpers
  def turno_do_fastpass(nome, duracao_time_frame: 15)
    @restaurante ||= restaurante_chamado("Darcy Ribeiro")
    inicio, fim = InscricaoFastpassHelpers::HORARIOS_TURNO.fetch(nome)
    turno = @restaurante.turnos.find_or_create_by!(nome:) do |novo|
      novo.hora_inicio = inicio
      novo.hora_fim = fim
    end
    expect(turno.dividir_em_time_frames!(duracao_time_frame)).to be(true) if turno.time_frames.empty?
    turno
  end

  def estudante_do_fastpass(matricula)
    User.find_or_create_by!(matricula:) do |novo|
      novo.nome = "Mariana Souza Silva"
      novo.password = "Senha123"
    end
  end

  def inscrever_no_fastpass(estudante, time_frame)
    inscricao = InscricaoFastpass.inscrever!(user: estudante, time_frame:)
    expect(inscricao).to be_persisted
    inscricao
  end
end

World(ValidacaoFastpassHelpers)

Dado(/^que o estudante "(\d+)" (não )?foi sorteado para o FastPass do (\S+)(?: no time-frame das (\d{2}:\d{2}) às (\d{2}:\d{2}))?$/) do |matricula, nao, turno, inicio, fim|
  @data_do_cenario ||= Date.current

  inscricao =
    if inicio
      turno_do_fastpass(turno, duracao_time_frame: HorarioEmMinutos.em_minutos(fim) - HorarioEmMinutos.em_minutos(inicio))
      inscrever_no_fastpass(estudante_do_fastpass(matricula), time_frame_do(turno, inicio, fim))
    else
      registro = turno_do_fastpass(turno)
      estudante = estudante_do_fastpass(matricula)
      estudante.inscricoes_fastpass.do_dia(@data_do_cenario).do_turno(registro).first ||
        inscrever_no_fastpass(estudante, registro.time_frames.first)
    end

  nao ? inscricao.nao_sorteado! : inscricao.sorteado!
end

Dado("que o horário atual é {hora}") do |hora|
  data = (@data_do_cenario ||= Date.current)
  horas, minutos = hora.split(":").map(&:to_i)
  travel_to Time.zone.local(data.year, data.month, data.day, horas, minutos)
end

Dado(/^que o estudante "(\d+)" já entrou pelo FastPass no (\S+)$/) do |matricula, turno|
  inscricao = User.find_by!(matricula:).inscricoes_fastpass
                  .do_dia(@data_do_cenario || Date.current).do_turno(turno_chamado(turno)).sorteado.first!
  inscricao.utilizado!
end

Quando("a Aplicação de Controle ler a identificação {string} na entrada do FastPass") do |identificacao|
  entrar_como_funcionario unless @funcionario

  visit operador_terminal_path
  fill_in "Identificação no FastPass", with: identificacao
  click_button "Validar FastPass"
end

Então("deve informar que o estudante está fora do time-frame do FastPass") do
  expect(page).to have_css("#resultado", text: "Fora do time-frame do FastPass")
end

Então("portanto, deve voltar para o final da fila.") do
  expect(page).to have_css("#resultado", text: "O estudante deve voltar para o final da fila")
end

Então("deve informar que o estudante não possui FastPass para o turno vigente") do
  expect(page).to have_css("#resultado", text: "Não possui FastPass para o turno vigente")
end

Então("deve informar que o FastPass já foi utilizado") do
  expect(page).to have_css("#resultado", text: "FastPass já foi utilizado")
end
