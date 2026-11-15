# language: pt
@issue_10
Funcionalidade: Cardápio da refeição atual
  Como estudante
  Quero ver o cardápio da refeição que esteja sendo servida agora
  Para saber quais opções (padrão, ovolactovegetariano e vegetariano estrito) estão disponíveis

  Contexto:
    Dado que o estudante está autenticado

  Cenário: Visualizar o cardápio completo do almoço
    Dado que é segunda-feira e o almoço está sendo servido
    Quando o estudante acessar o cardápio da refeição atual
    Então o sistema deve exibir as saladas, a guarnição, os acompanhamentos, a sobremesa e a bebida do almoço
    E deve exibir o prato principal de cada opção

  Esquema do Cenário: Visualizar as três opções de prato principal no almoço
    Dado que é segunda-feira e o almoço está sendo servido
    Quando o estudante acessar o cardápio da refeição atual
    Então o sistema deve exibir a opção <opção> com o prato "<prato>"

    Exemplos:
      | opção                  | prato                                       |
      | padrão                 | Frango assado com manjericão                |
      | ovolactovegetariana    | Quiche de legumes e lentilha gratinada      |
      | vegetariana estrita    | Refogado de lentilha, couve-flor e brócolis |

  Cenário: Visualizar o cardápio do café da manhã com as três opções de complemento
    Dado que é segunda-feira e o café da manhã está sendo servido
    Quando o estudante acessar o cardápio da refeição atual
    Então o sistema deve exibir o complemento padrão "Carne desfiada"
    E deve exibir o complemento ovolactovegetariano "Queijo muçarela"
    E deve exibir o complemento vegetariano estrito "Homus de grão de bico"

  Cenário: Visualizar a opção extra do café da manhã quando houver
    Dado que é terça-feira e o café da manhã está sendo servido
    Quando o estudante acessar o cardápio da refeição atual
    Então o sistema deve exibir a opção extra "Pão de queijo"

  Cenário: Não exibir opção extra no café da manhã quando não houver
    Dado que é segunda-feira e o café da manhã está sendo servido
    Quando o estudante acessar o cardápio da refeição atual
    Então o sistema não deve exibir nenhuma opção extra

  Cenário: Visualizar o cardápio do jantar com sopa e torrada
    Dado que é segunda-feira e o jantar está sendo servido
    Quando o estudante acessar o cardápio da refeição atual
    Então o sistema deve exibir a sopa "Creme de abóbora"
    E deve exibir a torrada
    E deve exibir o prato principal de cada opção

  Cenário: Não exibir as refeições que não estão sendo servidas
    Dado que é segunda-feira e o almoço está sendo servido
    Quando o estudante acessar o cardápio da refeição atual
    Então o sistema deve exibir o cardápio do almoço
    E não deve exibir o cardápio do café da manhã nem o do jantar

  Cenário: Acessar o cardápio fora do horário de refeição
    Dado que nenhuma refeição está sendo servida no momento
    Quando o estudante acessar o cardápio da refeição atual
    Então o sistema deve informar que não há refeição sendo servida no momento

  Cenário: Acessar o cardápio quando o cardápio do dia não está disponível
    Dado que o almoço está sendo servido
    E que não há cardápio cadastrado para o dia de hoje
    Quando o estudante acessar o cardápio da refeição atual
    Então o sistema deve informar que o cardápio do almoço não está disponível