require "prawn"
require "prawn/table"

# PDF do relatório global de operação: cabeçalho com o filtro de restaurante, uma tabela
# com os acessos e o total exportado.
class OperationReportPdf
  # Títulos das colunas da tabela.
  CABECALHO = [ "Restaurante", "Catraca", "Matrícula", "Status", "Data/Hora" ].freeze

  # Argumentos::
  #   +acessos+ (Enumerable de Acesso):: acessos a listar, já filtrados.
  #   +restaurante_filtro+ (String ou +nil+):: nome do restaurante filtrado; +nil+ vira "Todos".
  # Retorno:: a nova instância.
  # Efeitos colaterais:: nenhum.
  def initialize(acessos, restaurante_filtro: nil)
    @acessos = acessos
    @restaurante_filtro = restaurante_filtro
  end

  # Gera o documento.
  #
  # Argumentos:: nenhum.
  # Retorno:: +String+ binária com o conteúdo do PDF.
  # Efeitos colaterais:: nenhum (nada é gravado em disco).
  def render
    Prawn::Document.new do |pdf|
      cabecalho(pdf)
      tabela(pdf)
      totais(pdf)
    end.render
  end

  private
    # Título e filtro de restaurante aplicado.
    def cabecalho(pdf)
      pdf.text "Relatório Global de Operação - RU UnB", size: 16, style: :bold
      pdf.move_down 8
      pdf.text "Filtro de Restaurante: #{@restaurante_filtro.presence || 'Todos'}", size: 11
      pdf.move_down 12
    end

    # Tabela com uma linha por acesso.
    def tabela(pdf)
      pdf.table([ CABECALHO, *@acessos.map { |acesso| linha(acesso) } ], header: true, width: pdf.bounds.width)
    end

    # Linha da tabela para um acesso.
    def linha(acesso)
      [
        acesso.restaurante&.nome.to_s,
        acesso.catraca&.nome.to_s,
        acesso.identificacao.to_s,
        acesso.status.to_s,
        acesso.created_at.strftime("%d/%m/%Y %H:%M")
      ]
    end

    # Rodapé com o total de acessos exportados.
    def totais(pdf)
      pdf.move_down 10
      pdf.text "Total de acessos exportados: #{@acessos.count}", style: :bold
    end
end
