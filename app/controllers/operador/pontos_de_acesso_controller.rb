module Operador
  class PontosDeAcessoController < BaseController
    def show
      @restaurantes = Restaurante.ordenados
    end

    def update
      restaurante = Restaurante.find(params.expect(:restaurante_id))
      session[:restaurante_id] = restaurante.id
      session.delete(:catraca_id) if current_catraca && current_catraca.restaurante_id != restaurante.id

      redirect_to operador_terminal_path, notice: "Ponto de acesso configurado para o restaurante #{restaurante.nome}."
    end
  end
end
