module Operador
  class TerminalController < BaseController
    def show
      session[:catraca_id] = params[:catraca_id] if params[:catraca_id].present?
      @catraca = current_catraca
      @acesso = current_funcionario.acessos.includes(:user).find_by(id: params[:acesso])
      scope = @catraca ? @catraca.acessos : current_funcionario.acessos
      @ultimos_acessos = scope.includes(:user).order(id: :desc).limit(8)
      @tarifa = Tarifa.vigente_centavos
    end
  end
end
