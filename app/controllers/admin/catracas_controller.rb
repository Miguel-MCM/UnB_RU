module Admin
  # Cadastro, edição e remoção de catracas de um restaurante (apenas administradores).
  class CatracasController < BaseController
    before_action :set_catraca, only: %i[edit update destroy]
    before_action :set_restaurante, only: :create

    # Cadastra uma catraca no restaurante da rota.
    #
    # Argumentos:: +restaurante_id+ (rota) e +catraca[nome]+.
    # Retorno:: sem valor relevante.
    # Efeitos colaterais:: grava a catraca e redireciona para a gestão com aviso de sucesso;
    #                      se for inválida (ex.: nome repetido), não grava e redireciona
    #                      com o alerta dos erros. Restaurante inexistente responde 404.
    def create
      catraca = @restaurante.catracas.new(catraca_params)
      mensagem = if catraca.save
        { notice: "Catraca cadastrada." }
      else
        { alert: "Não foi possível adicionar a catraca: #{catraca.errors.full_messages.to_sentence}." }
      end

      redirect_to admin_restaurantes_path, mensagem
    end

    # Exibe o formulário de edição.
    #
    # Argumentos:: +id+ (rota).
    # Retorno:: renderiza a página; 404 se a catraca não existe.
    # Efeitos colaterais:: nenhum.
    def edit
    end

    # Renomeia a catraca.
    #
    # Argumentos:: +id+ (rota) e +catraca[nome]+.
    # Retorno:: sem valor relevante.
    # Efeitos colaterais:: grava e redireciona com aviso; se inválida, re-renderiza a
    #                      edição com status 422 sem gravar.
    def update
      if @catraca.update(catraca_params)
        redirect_to admin_restaurantes_path, notice: "Catraca atualizada."
      else
        render :edit, status: :unprocessable_content
      end
    end

    # Remove a catraca.
    #
    # Argumentos:: +id+ (rota).
    # Retorno:: sem valor relevante.
    # Efeitos colaterais:: apaga a catraca (os acessos dela ficam sem catraca) e
    #                      redireciona com aviso; 404 se não existe.
    def destroy
      @catraca.destroy!
      redirect_to admin_restaurantes_path, notice: "Catraca removida."
    end

    private
      # Carrega a catraca da rota (404 se não existe).
      def set_catraca
        @catraca = Catraca.find(params[:id])
      end

      # Carrega o restaurante da rota (404 se não existe).
      def set_restaurante
        @restaurante = Restaurante.find(params[:restaurante_id])
      end

      # Parâmetros permitidos: apenas +nome+.
      def catraca_params
        params.expect(catraca: [ :nome ])
      end
  end
end
