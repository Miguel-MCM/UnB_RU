# language: pt
@issue_3
Funcionalidade: Extrato e Histórico
  Como estudante
  Quero visualizar meu extrato de recargas e histórico de refeições
  Para ter controle sobre meus gastos e utilizações

  Contexto:
    Dado que o estudante está autenticado no Portal do Estudante RU UnB
    E acessou a seção de "Extrato"

  Cenário: Visualizar os indicadores consolidados do mês
    Dado que o estudante possui registros financeiros e de acesso no período atual
    Quando visualiza o topo da página de extrato
    Então o sistema deve exibir o "Total Gasto no Mês" com o valor correspondente
    E deve exibir o total de "Refeições Realizadas" detalhando a frequência
    E deve exibir o "Total Recarregado" junto com o saldo restante atual

  Cenário: Filtrar os lançamentos por período e tipo de refeição
    Dado que o estudante visualiza a tabela de lançamentos contábeis e registros de catraca
    Quando aplica o filtro de período de referência para "Últimos 30 dias (Maio/2024)"
    E seleciona o tipo de refeição desejado
    Então a listagem de lançamentos deve ser atualizada de acordo com os filtros selecionados

  Cenário: Exportar e imprimir o extrato de refeições
    Dado que o estudante está visualizando o extrato e histórico de refeições
    Quando clica no botão "Exportar PDF" ou no botão "Imprimir"
    Então o sistema deve gerar o documento correspondente para download ou impressão