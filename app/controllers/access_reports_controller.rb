# Relatório global de acessos (apenas administradores): lista, filtra, agrupa e exporta em
# PDF os acessos de todos os restaurantes e catracas. A regra fica em +RelatorioAcessos+.
class AccessReportsController < ApplicationController
  layout "operador"

  before_action :require_operador
  before_action :require_administrador
  before_action :carregar_relatorio

  # Exibe o relatório com os filtros dos parâmetros.
  #
  # Argumentos:: parâmetros opcionais +restaurante_nome+, +catraca_nome+ e +group_by+.
  # Retorno:: renderiza a página (sem valor relevante).
  # Efeitos colaterais:: nenhum (somente leitura).
  def index
  end

  # Exporta o relatório filtrado em PDF.
  #
  # Argumentos:: os mesmos filtros de #index.
  # Retorno:: sem valor relevante.
  # Efeitos colaterais:: com filtro inconsistente ou sem acessos, redireciona para o
  #                      relatório com um alerta; caso contrário envia
  #                      <tt>relatorio_operacao.pdf</tt> como anexo.
  def export_pdf
    if (impedimento = @relatorio.impedimento_de_exportacao)
      redirect_to access_reports_path(request.query_parameters), alert: impedimento
    else
      enviar_pdf
    end
  end

  private
    # +before_action+ que monta o +RelatorioAcessos+ (+@relatorio+) a partir dos parâmetros.
    def carregar_relatorio
      @relatorio = RelatorioAcessos.new(
        restaurante_nome: params[:restaurante_nome],
        catraca_nome: params[:catraca_nome],
        agrupar_por: params[:group_by]
      )
    end

    # Envia o PDF do relatório atual como anexo.
    def enviar_pdf
      pdf = OperationReportPdf.new(@relatorio.acessos, restaurante_filtro: @relatorio.restaurante&.nome)
      send_data pdf.render, filename: "relatorio_operacao.pdf", type: "application/pdf", disposition: "attachment"
    end
end
