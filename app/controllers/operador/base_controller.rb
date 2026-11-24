# Telas da Aplicação de Controle, usadas pelo operador no terminal de catraca.
module Operador
  # Base dos controllers do terminal de catraca: usa o layout operacional e
  # exige um funcionário logado. Também oferece os filtros de ponto de acesso
  # usados pelas telas de operação.
  class BaseController < ApplicationController
    layout "operador"

    before_action :require_operador

    private
      # +before_action+ das operações de controle de acesso: exige que o
      # operador tenha escolhido o restaurante quando há restaurantes cadastrados.
      #
      # Argumentos:: nenhum.
      # Retorno:: sem valor relevante.
      # Efeitos colaterais:: sem restaurante na sessão (e com restaurantes
      #                      cadastrados), redireciona para a seleção do ponto de
      #                      acesso com o alerta "Selecione o restaurante antes de
      #                      iniciar a operação.", interrompendo a action.
      def exigir_restaurante
        return unless Restaurante.selecao_obrigatoria? && current_restaurante.nil?

        redirect_to operador_ponto_de_acesso_path, alert: "Selecione o restaurante antes de iniciar a operação."
      end

      # +before_action+ que troca a catraca gerenciada quando a URL traz
      # <tt>?catraca_id=</tt>.
      #
      # Argumentos:: <tt>params[:catraca_id]</tt> (opcional).
      # Retorno:: sem valor relevante.
      # Efeitos colaterais:: com uma catraca existente, grava na sessão a catraca
      #                      e o restaurante dela e atualiza +@current_catraca+;
      #                      sem o parâmetro ou com uma catraca inexistente, não
      #                      muda nada.
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
