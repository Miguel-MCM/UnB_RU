# Controlador da área do estudante para listagem das notificações recebidas
# sobre os resultados dos sorteios do FastPass.
class NotificacoesController < ApplicationController
  before_action :require_login

  # Carrega as notificações do estudante autenticado ordenadas da mais recente
  # para a mais antiga.
  #
  # Argumentos:: nenhum (usa +current_user+).
  # Retorno:: +ActiveRecord::Relation+ atribuída a +@notificacoes+ (o Rails
  #           renderiza a view +notificacoes/index+).
  # Efeitos colaterais:: consulta o banco de dados, popula +@notificacoes+ e
  #                      renderiza a página HTML (ou redireciona para
  #                      +login_path+ via +require_login+).
  def index
    @notificacoes = current_user.notificacoes.recentes
  end
end
