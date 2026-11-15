require "prawn"
require "prawn/table"

class OperationReportPdf
  def initialize(acessos, restaurante_filtro: nil)
    @acessos = acessos
    @restaurante_filtro = restaurante_filtro
  end

  def render
    Prawn::Document.new do |pdf|
      pdf.text "Relatório Global de Operação - RU UnB", size: 16, style: :bold
      pdf.move_down 8
      pdf.text "Filtro de Restaurante: #{@restaurante_filtro.presence || 'Todos'}", size: 11
      pdf.move_down 12

      rows = [ [ "Restaurante", "Catraca", "Matrícula", "Status", "Data/Hora" ] ]
      @acessos.each do |acesso|
        rows << [
          acesso.restaurante&.nome.to_s,
          acesso.catraca&.nome.to_s,
          acesso.identificacao.to_s,
          acesso.status.to_s,
          acesso.created_at.strftime("%d/%m/%Y %H:%M")
        ]
      end

      pdf.table(rows, header: true, width: pdf.bounds.width)
      pdf.move_down 10
      pdf.text "Total de acessos exportados: #{@acessos.count}", style: :bold
    end.render
  end
end
