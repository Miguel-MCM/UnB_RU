module Admin
  class TurnosController < BaseController
    before_action :set_restaurante

    def index
      carregar_turnos
      @turno = Turno.new
    end

    def create
      @turno = Turno.new(restaurante: @restaurante, **turno_params)

      if @turno.save
        redirect_to admin_restaurante_turnos_path(@restaurante), notice: "Turno cadastrado."
      else
        carregar_turnos
        flash.now[:alert] = @turno.errors.full_messages.to_sentence
        render :index, status: :unprocessable_content
      end
    end

    private
      def set_restaurante
        @restaurante = Restaurante.find(params[:restaurante_id])
      end

      def carregar_turnos
        @turnos = @restaurante.turnos.includes(:time_frames)
      end

      def turno_params
        params.expect(turno: [ :nome, :hora_inicio, :hora_fim ])
      end
  end
end
