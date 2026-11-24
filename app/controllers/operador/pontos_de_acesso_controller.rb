module Operador
  # Configuração do ponto de acesso: o restaurante que o operador vai gerenciar
  # (<tt>/operador/ponto_de_acesso</tt>).
  class PontosDeAcessoController < BaseController
    # GET /operador/ponto_de_acesso: lista os restaurantes para escolha.
    #
    # Argumentos:: nenhum.
    # Retorno:: renderiza +pontos_de_acesso/show+ com +@restaurantes+ em ordem alfabética.
    # Efeitos colaterais:: nenhum.
    def show
      @restaurantes = Restaurante.ordenados
    end

    # PATCH /operador/ponto_de_acesso: grava o restaurante escolhido.
    #
    # Argumentos:: <tt>params[:restaurante_id]</tt>.
    # Retorno:: redireciona para o terminal com o aviso "Ponto de acesso
    #           configurado para o restaurante ..."; responde 404 para um
    #           restaurante inexistente e 400 sem o parâmetro.
    # Efeitos colaterais:: grava o restaurante na sessão e descarta a catraca
    #                      escolhida quando ela é de outro restaurante.
    def update
      restaurante = Restaurante.find(params.expect(:restaurante_id))
      configurar_ponto_de_acesso(restaurante)

      redirect_to operador_terminal_path, notice: "Ponto de acesso configurado para o restaurante #{restaurante.nome}."
    end

    private
      # Grava o restaurante do ponto de acesso na sessão.
      #
      # Argumentos:: +restaurante+ (Restaurante): restaurante escolhido.
      # Retorno:: sem valor relevante.
      # Efeitos colaterais:: grava <tt>session[:restaurante_id]</tt> e apaga
      #                      <tt>session[:catraca_id]</tt> quando a catraca
      #                      atual pertence a outro restaurante.
      def configurar_ponto_de_acesso(restaurante)
        session[:restaurante_id] = restaurante.id
        session.delete(:catraca_id) unless current_catraca.nil? || current_catraca.restaurante_id == restaurante.id
      end
  end
end
