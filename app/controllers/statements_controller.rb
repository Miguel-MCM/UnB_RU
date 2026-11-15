class StatementsController < ApplicationController
  before_action :require_login
  before_action :set_extrato

  def index
  end

  def export_pdf
    if @extrato.vazio?
      return redirect_to statements_path(periodo: params[:periodo], tipo: params[:tipo]),
                         alert: "Não há registros para exportar."
    end

    send_data ExtratoPdf.new(@extrato, current_user).render,
              filename: "extrato-#{current_user.matricula}.pdf", type: "application/pdf", disposition: "attachment"
  end

  private
    def set_extrato
      @extrato = Extrato.new(current_user, periodo: params[:periodo], tipo: params[:tipo])
    end
end
