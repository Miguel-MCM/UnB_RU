module Operador
  class HistoricosController < BaseController
    before_action :selecionar_catraca

    def show
      @catraca = current_catraca
      @acessos = if @catraca
        @catraca.acessos.includes(:user).order(created_at: :desc)
      else
        Acesso.none
      end
    end
  end
end
