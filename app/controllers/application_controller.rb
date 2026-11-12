class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_user

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_authentication
    redirect_to "/up", alert: "Acesso não autorizado" unless current_user
  end

  def require_admin
    if current_user.nil? || !current_user.admin?
      render plain: "Acesso restrito a administradores", status: :forbidden
    end
  end
end