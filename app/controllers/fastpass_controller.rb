class FastpassController < ApplicationController
  before_action :require_login

  def show
    @restaurantes = Restaurante.com_turnos.ordenados.includes(turnos: :time_frames)
    @inscricoes = current_user.inscricoes_fastpass.do_dia.includes(:time_frame).index_by(&:time_frame_id)
    @turnos_inscritos = @inscricoes.values.map { |inscricao| inscricao.time_frame.turno_id }
  end
end
