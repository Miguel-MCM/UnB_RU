module Operador
  class TerminalController < BaseController
    before_action :selecionar_catraca, :exigir_restaurante

    def show
      @catraca = current_catraca
      @restaurante = current_restaurante
      @acesso = current_funcionario.acessos.includes(:user).find_by(id: params[:acesso])
      scope = @catraca ? @catraca.acessos : current_funcionario.acessos
      @ultimos_acessos = scope.includes(:user).order(id: :desc).limit(8)
      @tarifa = Tarifa.vigente_centavos
    end
  end
end
