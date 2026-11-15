module Admin
  class RestaurantesController < BaseController
    before_action :set_restaurante, only: %i[edit update destroy]

    def index
      @restaurantes = Restaurante.ordenados.includes(:catracas)
    end

    def new
      @restaurante = Restaurante.new
    end

    def create
      @restaurante = Restaurante.new(restaurante_params)

      if @restaurante.save
        redirect_to admin_restaurantes_path, notice: "Restaurante cadastrado."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @restaurante.update(restaurante_params)
        redirect_to admin_restaurantes_path, notice: "Restaurante atualizado."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @restaurante.destroy!
      redirect_to admin_restaurantes_path, notice: "Restaurante removido."
    end

    private
      def set_restaurante
        @restaurante = Restaurante.find(params[:id])
      end

      def restaurante_params
        params.expect(restaurante: [ :nome ])
      end
  end
end
