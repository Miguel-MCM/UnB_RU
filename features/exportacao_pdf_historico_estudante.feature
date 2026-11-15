# language: pt
@issue_11
Funcionalidade: Exportação em PDF do extrato e histórico de refeições
  Como estudante
  Quero exportar meu extrato e histórico de refeições como PDF
  Para controlar melhor as minhas finanças

  Contexto:
    Dado que o estudante de matrícula "231012345" está autenticado no Portal do Estudante RU UnB
    E acessou a seção de "Extrato"

  Cenário: Exportar o extrato e o histórico de refeições em PDF
    Dado que o estudante possui recargas e refeições registradas no período atual
    Quando o estudante exportar o extrato em PDF
    Então o sistema deve gerar um arquivo PDF para download
    E o PDF deve conter as recargas e as refeições realizadas

  Cenário: O PDF deve exibir os totais do período
    Dado que o estudante possui recargas e refeições registradas no período atual
    Quando o estudante exportar o extrato em PDF
    Então o PDF deve exibir o total gasto, o total recarregado e o saldo restante

  Cenário: O PDF deve respeitar os filtros aplicados
    Dado que o estudante filtrou o extrato por período e por tipo de refeição
    Quando o estudante exportar o extrato em PDF
    Então o PDF deve conter apenas os lançamentos correspondentes aos filtros selecionados

  Cenário: O PDF deve conter apenas os dados do próprio estudante
    Dado que existem registros do estudante de matrícula "231012345"
    E que existem registros do estudante de matrícula "222098765"
    Quando o estudante exportar o extrato em PDF
    Então o PDF deve conter apenas os registros do estudante de matrícula "231012345"

  Cenário: Exportar o extrato sem nenhum registro
    Dado que o estudante não possui recargas nem refeições registradas
    Quando o estudante exportar o extrato em PDF
    Então o sistema deve informar que não há registros para exportar
    E nenhum arquivo PDF deve ser gerado