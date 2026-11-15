module Operador
  class BaseController < ApplicationController
    layout "operador"

    before_action :require_operador

    private
      def exigir_restaurante
        return unless Restaurante.selecao_obrigatoria? && current_restaurante.nil?

        redirect_to operador_ponto_de_acesso_path, alert: "Selecione o restaurante antes de iniciar a operação."
      end

      def selecionar_catraca
        return if params[:catraca_id].blank?

        catraca = Catraca.find_by(id: params[:catraca_id])
        return unless catraca

        session[:catraca_id] = catraca.id
        session[:restaurante_id] = catraca.restaurante_id
        @current_catraca = catraca
        @current_restaurante = nil
      end
  end
end
