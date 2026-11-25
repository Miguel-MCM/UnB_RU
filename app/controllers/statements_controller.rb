# Controlador responsável pela exibição e exportação em PDF do extrato do estudante.
class StatementsController < ApplicationController
  before_action :require_login
  before_action :set_extrato

  # Exibe a página de extrato com indicadores mensais e lançamentos filtrados.
  #
  # Argumentos:: nenhum.
  # Retorno:: +nil+ (renderiza a view +statements/index+).
  # Efeitos colaterais:: utiliza +@extrato+ carregado pelo filtro +set_extrato+;
  #                      redireciona para o login se o estudante não estiver autenticado.
  def index
  end

  # Gera e envia o PDF do extrato filtrado para download, ou redireciona se vazio.
  #
  # Argumentos:: nenhum.
  # Retorno:: resposta binária PDF (+send_data+) quando há lançamentos ou
  #           redirecionamento HTTP para +statements_path+ quando o extrato está vazio.
  # Efeitos colaterais:: redireciona para +statements_path+ com +alert+ quando vazio;
  #                      envia arquivo PDF como anexo na resposta HTTP quando há dados.
  def export_pdf
    if @extrato.vazio?
      return redirect_to statements_path(periodo: params[:periodo], tipo: params[:tipo]),
                         alert: "Não há registros para exportar."
    end

    send_data ExtratoPdf.new(@extrato, current_user).render,
              filename: "extrato-#{current_user.matricula}.pdf", type: "application/pdf", disposition: "attachment"
  end

  private
    # Instancia o objeto +Extrato+ para o estudante atual aplicando os filtros da URL.
    #
    # Argumentos:: nenhum (lê +params[:periodo]+ e +params[:tipo]+).
    # Retorno:: instância de +Extrato+.
    # Efeitos colaterais:: define a variável de instância +@extrato+.
    def set_extrato
      @extrato = Extrato.new(current_user, periodo: params[:periodo], tipo: params[:tipo])
    end
end
