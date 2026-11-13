class InscricoesFastpassController < ApplicationController
  before_action :require_login

  def create
    time_frame = TimeFrame.find(params.expect(:time_frame_id))
    inscricao = InscricaoFastpass.inscrever!(user: current_user, time_frame:)

    if inscricao.persisted?
      redirect_to fastpass_path, notice: "Inscrição realizada no time-frame das #{time_frame.horario} do #{time_frame.turno.nome}."
    else
      redirect_to fastpass_path, alert: inscricao.errors.full_messages.to_sentence
    end
  end
end
