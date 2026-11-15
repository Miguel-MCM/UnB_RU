module Operador
  class AcessosController < BaseController
    def create
      if params[:identificacao].blank?
        return redirect_to operador_terminal_path, alert: "Informe a identificação do estudante."
      end

      acesso = Acesso.registrar_leitura!(params[:identificacao], funcionario: current_funcionario)
      redirect_to operador_terminal_path(acesso:)
    end
  end
end
