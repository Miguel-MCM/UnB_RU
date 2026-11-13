module Operador
  class TerminalController < BaseController
    def show
      @acesso = current_funcionario.acessos.includes(:user).find_by(id: params[:acesso])
      @ultimos_acessos = current_funcionario.acessos.includes(:user).order(id: :desc).limit(8)
      @tarifa = Tarifa.vigente_centavos
    end
  end
end
