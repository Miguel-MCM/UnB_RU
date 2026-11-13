# language: pt
@issue_12
Funcionalidade: Exportação em PDF do relatório de operação
  Como administrador geral do sistema
  Quero exportar o relatório global de operação em PDF
  Para realizar auditoria interna

  Contexto:
    Dado que o administrador está autenticado

  Cenário: Exportar o relatório global de operação em PDF
    Dado que existem acessos registrados nos restaurantes "Darcy Ribeiro" e "Gama"
    Quando o administrador exportar o relatório global de operação em PDF
    Então o sistema deve gerar um arquivo PDF para download
    E o PDF deve conter os acessos de todos os restaurantes

  Cenário: Exportar o relatório com filtro aplicado
    Dado que existem acessos registrados nos restaurantes "Darcy Ribeiro" e "Gama"
    E que o relatório está filtrado pelo restaurante "Darcy Ribeiro"
    Quando o administrador exportar o relatório global de operação em PDF
    Então o PDF deve conter apenas os acessos do restaurante "Darcy Ribeiro"

  Cenário: Exportar o relatório sem acessos registrados
    Dado que não existem acessos registrados
    Quando o administrador exportar o relatório global de operação em PDF
    Então o sistema deve informar que não há dados para exportar
    E nenhum arquivo PDF deve ser gerado