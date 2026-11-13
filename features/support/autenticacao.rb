module AutenticacaoHelpers
  def entrar_como_funcionario(administrador: false)
    @funcionario ||= Funcionario.create!(
      nome: administrador ? "Fernando Albuquerque" : "Carlos Mendes",
      matricula: administrador ? "1083921" : "1984201",
      password: "Operador123",
      administrador:
    )

    visit operador_login_path
    fill_in "Matrícula SIAPE ou Usuário SIGAA / gov.br", with: @funcionario.matricula
    fill_in "Senha de Acesso", with: @funcionario.password
    click_button "Entrar no Sistema"
  end

  def entrar_como_estudante
    @estudante ||= User.create!(nome: "Ana Beatriz Silva", matricula: "221045999", password: "Senha123", saldo_centavos: 1800)

    visit login_path
    fill_in "Matrícula SIGAA ou SIAPE", with: @estudante.matricula
    fill_in "Senha de Acesso", with: "Senha123"
    click_button "Entrar no Sistema"
  end
end

World(AutenticacaoHelpers)
