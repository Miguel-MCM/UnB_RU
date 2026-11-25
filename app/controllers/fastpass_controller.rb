# Controlador da área do estudante para visualização dos turnos, time-frames
# disponíveis e inscrições ativas do dia no FastPass.
class FastpassController < ApplicationController
  before_action :require_login

  # Carrega os restaurantes com turnos e time-frames disponíveis e identifica
  # em quais time-frames e turnos o estudante autenticado já está inscrito hoje.
  #
  # Argumentos:: nenhum (usa o usuário da sessão em +current_user+).
  # Retorno:: +Array<Integer>+ atribuído a +@turnos_inscritos+ (o Rails renderiza
  #           a view +fastpass/show+).
  # Efeitos colaterais:: consulta o banco de dados, popula as variáveis de
  #                      instância +@restaurantes+, +@inscricoes+ e
  #                      +@turnos_inscritos+ e renderiza a página HTML (ou
  #                      redireciona para +login_path+ via +require_login+).
  def show
    @restaurantes = Restaurante.com_turnos.ordenados.includes(turnos: :time_frames)
    @inscricoes = current_user.inscricoes_fastpass.do_dia.includes(:time_frame).index_by(&:time_frame_id)
    @turnos_inscritos = @inscricoes.values.map { |inscricao| inscricao.time_frame.turno_id }
  end
end
