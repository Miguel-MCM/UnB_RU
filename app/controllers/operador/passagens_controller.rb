module Operador
  class PassagensController < BaseController
    def create
      acesso = current_funcionario.acessos.find(params[:acesso_id])
      acesso.confirmar_passagem!

      redirect_to operador_terminal_path(acesso:)
    end
  end
end
