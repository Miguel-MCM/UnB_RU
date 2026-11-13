# language: pt
@issue_4
Funcionalidade: Autenticação do funcionário
  Como funcionário do restaurante
  Quero fazer login na aplicação de controle
  Para autenticar minha sessão e operar o sistema de forma segura

  Contexto:
    Dado que o funcionário acessou a página de "Autenticação do Operador"

  Cenário: Realizar login com credenciais válidas do operador
    Dado que o funcionário preenche o campo "Matrícula SIAPE ou Usuário SIGAA / gov.br" com "1984201"
    E preenche o campo "Senha de Acesso" com uma senha válida
    Quando clica no botão "Entrar no Sistema"
    Então a sessão do operador deve ser autenticada com sucesso
    E o sistema deve liberar o terminal de catraca para operação

  Cenário: Tentar realizar login com campos obrigatórios vazios
    Dado que o funcionário deixa os campos de credenciais em branco
    Quando clica no botão "Entrar no Sistema"
    Então o sistema deve exibir mensagens de campo obrigatório
    E a sessão não deve ser iniciada

  Cenário: Exibir restrições de obrigatoriedade nos campos de acesso
    Dado que o formulário de autenticação está visível para o operador
    Então os campos "Matrícula SIAPE ou Usuário SIGAA / gov.br" e "Senha de Acesso" devem ser sinalizados como obrigatórios