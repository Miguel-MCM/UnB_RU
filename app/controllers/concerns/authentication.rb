# Sessões do sistema, incluído em ApplicationController.
#
# Guarda na sessão o estudante logado (<tt>session[:user_id]</tt>), o
# funcionário logado (<tt>session[:funcionario_id]</tt>) e o ponto de acesso
# escolhido pelo operador (<tt>session[:restaurante_id]</tt> e
# <tt>session[:catraca_id]</tt>). Os métodos +current_*+ também ficam
# disponíveis nas views, e os +require_*+ são usados como +before_action+.
module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :current_funcionario, :current_catraca, :current_restaurante
  end

  private
    # Estudante logado no Portal do Estudante.
    #
    # Argumentos:: nenhum.
    # Retorno:: o User da sessão; +nil+ sem login ou se o usuário foi removido.
    # Efeitos colaterais:: memoriza o resultado em +@current_user+.
    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end

    # Funcionário logado na Aplicação de Controle.
    #
    # Argumentos:: nenhum.
    # Retorno:: o Funcionario da sessão; +nil+ sem login ou se ele foi removido.
    # Efeitos colaterais:: memoriza o resultado em +@current_funcionario+.
    def current_funcionario
      @current_funcionario ||= Funcionario.find_by(id: session[:funcionario_id]) if session[:funcionario_id]
    end

    # Catraca escolhida pelo operador para o histórico local e o terminal.
    #
    # Argumentos:: nenhum.
    # Retorno:: a Catraca da sessão; +nil+ quando nenhuma foi escolhida ou ela foi removida.
    # Efeitos colaterais:: memoriza o resultado em +@current_catraca+.
    def current_catraca
      @current_catraca ||= Catraca.find_by(id: session[:catraca_id]) if session[:catraca_id]
    end

    # Restaurante do ponto de acesso configurado pelo operador.
    #
    # Argumentos:: nenhum.
    # Retorno:: o Restaurante da sessão; +nil+ quando nenhum foi escolhido ou ele foi removido.
    # Efeitos colaterais:: memoriza o resultado em +@current_restaurante+.
    def current_restaurante
      @current_restaurante ||= Restaurante.find_by(id: session[:restaurante_id]) if session[:restaurante_id]
    end

    # +before_action+ das páginas do estudante.
    #
    # Argumentos:: nenhum.
    # Retorno:: sem valor relevante.
    # Efeitos colaterais:: sem estudante logado, redireciona para <tt>/login</tt>
    #                      com o alerta "Acesse sua conta para continuar.",
    #                      interrompendo a action.
    def require_login
      redirect_to login_path, alert: "Acesse sua conta para continuar." unless current_user
    end

    # +before_action+ das páginas da Aplicação de Controle.
    #
    # Argumentos:: nenhum.
    # Retorno:: sem valor relevante.
    # Efeitos colaterais:: sem funcionário logado, redireciona para
    #                      <tt>/operador/login</tt> com o alerta "Autentique-se
    #                      como operador para continuar.", interrompendo a action.
    def require_operador
      redirect_to operador_login_path, alert: "Autentique-se como operador para continuar." unless current_funcionario
    end

    # +before_action+ da administração. Deve rodar depois de #require_operador,
    # que garante o funcionário logado.
    #
    # Argumentos:: nenhum.
    # Retorno:: sem valor relevante.
    # Efeitos colaterais:: quando o funcionário não é administrador, redireciona
    #                      para o terminal com o alerta "Área restrita a
    #                      administradores.", interrompendo a action.
    def require_administrador
      redirect_to operador_terminal_path, alert: "Área restrita a administradores." unless current_funcionario.administrador?
    end
end
