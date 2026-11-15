module Admin
  class TimeFramesController < BaseController
    def create
      turno = Turno.find(params[:turno_id])

      if turno.dividir_em_time_frames!(params.expect(:duracao_time_frame_min))
        redirect_to admin_restaurante_turnos_path(turno.restaurante), notice: "Time-frames atualizados."
      else
        redirect_to admin_restaurante_turnos_path(turno.restaurante),
                    alert: "Não foi possível dividir o turno: #{turno.errors.full_messages.to_sentence}."
      end
    end
  end
end
