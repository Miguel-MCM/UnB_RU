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
end

World(AutenticacaoHelpers)
