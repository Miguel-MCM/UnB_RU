class FastpassController < ApplicationController
  before_action :require_login

  def show
    @restaurantes = Restaurante.com_turnos.ordenados.includes(turnos: :time_frames)
  end
end
