module Admin
  class CatracasController < BaseController
    before_action :set_catraca, only: %i[edit update destroy]

    def create
      catraca = Restaurante.find(params[:restaurante_id]).catracas.new(catraca_params)

      if catraca.save
        redirect_to admin_restaurantes_path, notice: "Catraca cadastrada."
      else
        redirect_to admin_restaurantes_path,
                    alert: "Não foi possível adicionar a catraca: #{catraca.errors.full_messages.to_sentence}."
      end
    end

    def edit
    end

    def update
      if @catraca.update(catraca_params)
        redirect_to admin_restaurantes_path, notice: "Catraca atualizada."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @catraca.destroy!
      redirect_to admin_restaurantes_path, notice: "Catraca removida."
    end

    private
      def set_catraca
        @catraca = Catraca.find(params[:id])
      end

      def catraca_params
        params.expect(catraca: [ :nome ])
      end
  end
end
