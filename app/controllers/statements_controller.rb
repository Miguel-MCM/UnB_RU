class StatementsController < ApplicationController
  before_action :require_login

  def index
    load_statement_data
  end

  def export_pdf
    load_statement_data

    if @recargas.empty? && @acessos.empty?
      redirect_to statements_path(request.query_parameters), alert: "Não há registros para exportar"
      return
    end

    pdf_data = StudentStatementPdf.new(
      user: current_user,
      recargas: @recargas,
      acessos: @acessos,
      total_gasto_centavos: @total_gasto_centavos,
      total_recarregado_centavos: @total_recarregado_centavos,
      filtro_periodo: params[:periodo],
      filtro_refeicao: params[:tipo_refeicao]
    ).render

    send_data pdf_data,
              filename: "extrato_estudante_#{current_user.matricula}.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end

  private
    def load_statement_data
      @recargas = current_user.recargas.order(created_at: :desc)
      @acessos = current_user.acessos.confirmado.order(created_at: :desc)

      if params[:periodo] == "mes_atual"
        inicio = Time.current.beginning_of_month
        fim = Time.current.end_of_month
        @recargas = @recargas.where(created_at: inicio..fim)
        @acessos = @acessos.where(created_at: inicio..fim)
      elsif params[:periodo] == "ultimos_30_dias"
        @recargas = @recargas.where("created_at >= ?", 30.days.ago.beginning_of_day)
        @acessos = @acessos.where("created_at >= ?", 30.days.ago.beginning_of_day)
      end

      if params[:tipo_refeicao].present?
        @recargas = Recarga.none
        @acessos = @acessos.select { |acesso| meal_slug(acesso.created_at) == params[:tipo_refeicao] }
      end

      @total_gasto_centavos = @acessos.sum(&:valor_centavos)
      @total_recarregado_centavos = @recargas.sum(&:valor_centavos)
    end

    def meal_slug(timestamp)
      hour = timestamp.hour
      if hour < 10
        "cafe_da_manha"
      elsif hour < 15
        "almoco"
      else
        "jantar"
      end
    end
end
