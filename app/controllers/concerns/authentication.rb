module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :current_funcionario
  end

  private
    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end

    def current_funcionario
      @current_funcionario ||= Funcionario.find_by(id: session[:funcionario_id]) if session[:funcionario_id]
    end

    def require_login
      redirect_to login_path, alert: "Acesse sua conta para continuar." unless current_user
    end

    def require_operador
      redirect_to operador_login_path, alert: "Autentique-se como operador para continuar." unless current_funcionario
    end

    def require_administrador
      redirect_to operador_terminal_path, alert: "Área restrita a administradores." unless current_funcionario.administrador?
    end
end
