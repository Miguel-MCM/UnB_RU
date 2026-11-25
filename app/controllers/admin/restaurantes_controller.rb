module Admin
  # Gestão de restaurantes (apenas administradores): listagem com catracas, cadastro,
  # edição e remoção.
  class RestaurantesController < BaseController
    before_action :set_restaurante, only: %i[edit update destroy]

    # Lista os restaurantes em ordem alfabética, com as catracas.
    #
    # Argumentos:: nenhum.
    # Retorno:: renderiza a página.
    # Efeitos colaterais:: nenhum (somente leitura).
    def index
      @restaurantes = Restaurante.ordenados.includes(:catracas)
    end

    # Exibe o formulário de novo restaurante.
    #
    # Argumentos:: nenhum.
    # Retorno:: renderiza a página.
    # Efeitos colaterais:: nenhum.
    def new
      @restaurante = Restaurante.new
    end

    # Cadastra um restaurante.
    #
    # Argumentos:: +restaurante[nome]+.
    # Retorno:: sem valor relevante.
    # Efeitos colaterais:: se válido, grava e redireciona para a gestão com aviso de
    #                      sucesso; se inválido (nome em branco ou repetido), não grava e
    #                      re-renderiza o formulário com status 422.
    def create
      @restaurante = Restaurante.new(restaurante_params)

      if @restaurante.save
        redirect_to admin_restaurantes_path, notice: "Restaurante cadastrado."
      else
        render :new, status: :unprocessable_content
      end
    end

    # Exibe o formulário de edição.
    #
    # Argumentos:: +id+ (rota).
    # Retorno:: renderiza a página; 404 se o restaurante não existe.
    # Efeitos colaterais:: nenhum.
    def edit
    end

    # Renomeia o restaurante.
    #
    # Argumentos:: +id+ (rota) e +restaurante[nome]+.
    # Retorno:: sem valor relevante.
    # Efeitos colaterais:: se válido, grava e redireciona com aviso; se inválido, não
    #                      grava e re-renderiza a edição com status 422.
    def update
      if @restaurante.update(restaurante_params)
        redirect_to admin_restaurantes_path, notice: "Restaurante atualizado."
      else
        render :edit, status: :unprocessable_content
      end
    end

    # Remove o restaurante.
    #
    # Argumentos:: +id+ (rota).
    # Retorno:: sem valor relevante.
    # Efeitos colaterais:: apaga o restaurante, suas catracas e turnos (os acessos ficam
    #                      sem restaurante) e redireciona com aviso; 404 se não existe.
    def destroy
      @restaurante.destroy!
      redirect_to admin_restaurantes_path, notice: "Restaurante removido."
    end

    private
      # Carrega o restaurante da rota (404 se não existe).
      def set_restaurante
        @restaurante = Restaurante.find(params[:id])
      end

      # Parâmetros permitidos: apenas +nome+.
      def restaurante_params
        params.expect(restaurante: [ :nome ])
      end
  end
end
