class NotificacoesController < ApplicationController
  before_action :require_login

  def index
    @notificacoes = current_user.notificacoes.recentes
  end
end
