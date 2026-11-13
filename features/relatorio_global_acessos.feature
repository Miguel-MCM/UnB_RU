# language: pt
@issue_9
Funcionalidade: Relatório global de acessos
  Como administrador
  Quero visualizar o histórico completo de todos os acessos do campus, podendo filtrar e agrupar os dados por restaurante e por catraca específica
  Para ter uma visão gerencial de toda a operação

  Contexto:
    Dado que o administrador está autenticado

  Cenário: Visualizar o histórico completo de acessos do campus
    Dado que existem acessos registrados nos restaurantes "Darcy Ribeiro" e "Gama"
    Quando o administrador acessar o relatório global de acessos
    Então o relatório deve exibir os acessos de todos os restaurantes

  Cenário: Filtrar os acessos por restaurante
    Dado que existem acessos registrados nos restaurantes "Darcy Ribeiro" e "Gama"
    Quando o administrador filtrar o relatório pelo restaurante "Darcy Ribeiro"
    Então o relatório deve exibir apenas os acessos do restaurante "Darcy Ribeiro"

  Cenário: Filtrar os acessos por catraca específica
    Dado que as catracas "Entrada 1" e "Entrada 2" estão associadas ao restaurante "Darcy Ribeiro"
    E que existem acessos registrados em ambas as catracas
    Quando o administrador filtrar o relatório pela catraca "Entrada 1"
    Então o relatório deve exibir apenas os acessos da catraca "Entrada 1"

  Cenário: Agrupar os acessos por restaurante
    Dado que existem acessos registrados nos restaurantes "Darcy Ribeiro" e "Gama"
    Quando o administrador agrupar o relatório por restaurante
    Então o relatório deve exibir o total de acessos de cada restaurante separadamente

  Cenário: Agrupar os acessos por catraca
    Dado que as catracas "Entrada 1" e "Entrada 2" estão associadas ao restaurante "Darcy Ribeiro"
    E que existem acessos registrados em ambas as catracas
    Quando o administrador agrupar o relatório por catraca
    Então o relatório deve exibir o total de acessos de cada catraca separadamente

  Cenário: Filtrar por restaurante sem acessos registrados
    Dado que o restaurante "Gama" não possui acessos registrados
    Quando o administrador filtrar o relatório pelo restaurante "Gama"
    Então o relatório deve informar que não há acessos para o filtro selecionado

  Cenário: Filtrar por uma catraca que não pertence ao restaurante selecionado
    Dado que a catraca "Entrada 1" está associada ao restaurante "Darcy Ribeiro"
    Quando o administrador filtrar o relatório pelo restaurante "Gama" e pela catraca "Entrada 1"
    Então o relatório deve informar que a catraca "Entrada 1" não pertence ao restaurante "Gama"