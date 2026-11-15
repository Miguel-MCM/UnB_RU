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

  def selecionar_restaurante(nome)
    visit operador_ponto_de_acesso_path
    click_button nome
  end

  def configurar_ponto_de_acesso(nome)
    entrar_como_funcionario unless @funcionario
    @restaurante = Restaurante.find_or_create_by!(nome:)
    selecionar_restaurante(nome)
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
