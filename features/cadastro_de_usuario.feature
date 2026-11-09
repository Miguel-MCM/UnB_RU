# language: pt
@issue_1
Funcionalidade: Cadastro de usuário
  Como estudante
  Quero me cadastrar no sistema utilizando minha matrícula
  Para que eu possa criar minha conta de acesso ao RU

  Contexto:
    Dado que o estudante acessou a tela de cadastro de usuário

  Cenário: Realizar cadastro com sucesso preenchendo os dados obrigatórios
    Dado que o estudante preenche o campo "Nome Completo" com "João da Silva"
    E preenche o campo "Matrícula SIGAA ou SIAPE" com "2023123456"
    E preenche o campo "Senha de Acesso" com "SenhaForte123"
    E preenche o campo "Confirmar Senha" com "SenhaForte123"
    Quando clica no botão "Criar Minha Conta"
    Então o sistema deve criar a conta de acesso com sucesso
    E exibir a confirmação de cadastro

  Cenário: Tentar cadastrar com senhas divergentes
    Dado que o estudante preenche o campo "Nome Completo" com "Maria Souza"
    E preenche o campo "Matrícula SIGAA ou SIAPE" com "2023654321"
    E preenche o campo "Senha de Acesso" com "Senha123"
    E preenche o campo "Confirmar Senha" com "OutraSenha Diferente"
    Quando clica no botão "Criar Minha Conta"
    Então o sistema deve exibir uma mensagem de erro informando que as senhas não conferem
    Mas a conta não deve ser criada

  Cenário: Navegar para a tela de login a partir do formulário de cadastro
    Dado que o estudante está visualizando a tela de cadastro de usuário
    Quando clica no link "Já possui uma conta? Acesse aqui"
    Então o sistema deve redirecioná-lo para a página de autenticação