module Operador
  class HistoricosController < BaseController
    def show
      session[:catraca_id] = params[:catraca_id] if params[:catraca_id].present?
      @catraca = current_catraca
      @acessos = if @catraca
        @catraca.acessos.includes(:user).order(created_at: :desc)
      else
        Acesso.none
      end
    end
  end
end
