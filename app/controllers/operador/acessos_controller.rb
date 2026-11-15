module Operador
  class AcessosController < BaseController
    before_action :exigir_restaurante

    def create
      if params[:identificacao].blank?
        return redirect_to operador_terminal_path, alert: "Informe a identificação do estudante."
      end

      acesso = Acesso.registrar_leitura!(
        params[:identificacao],
        funcionario: current_funcionario,
        restaurante: current_restaurante,
        catraca: current_catraca,
        modalidade: params[:modalidade].presence_in(Acesso.modalidades.keys) || "comum"
      )
      redirect_to operador_terminal_path(acesso:)
    end
  end
end
