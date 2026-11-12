module AutenticacaoHelpers
  def entrar_como_funcionario
    @funcionario ||= Funcionario.create!(nome: "Carlos Mendes", matricula: "1984201", password: "Operador123")

    visit operador_login_path
    fill_in "Matrícula SIAPE ou Usuário SIGAA / gov.br", with: @funcionario.matricula
    fill_in "Senha de Acesso", with: @funcionario.password
    click_button "Entrar no Sistema"
  end
end

World(AutenticacaoHelpers)
