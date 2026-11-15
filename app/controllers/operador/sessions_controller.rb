module Operador
  class SessionsController < BaseController
    skip_before_action :require_operador

    def new
      @login = LoginOperador.new
    end

    def create
      @login = LoginOperador.new(login_params)

      if (funcionario = @login.funcionario)
        reset_session
        session[:funcionario_id] = funcionario.id
        redirect_to destino_apos_login(funcionario)
      else
        flash.now[:alert] = "Matrícula ou senha inválidas." if @login.errors.empty?
        render :new, status: :unprocessable_content
      end
    end

    def destroy
      reset_session
      redirect_to operador_login_path, notice: "Sessão do operador encerrada."
    end

    private
      def destino_apos_login(funcionario)
        if funcionario.administrador? then admin_restaurantes_path
        elsif Restaurante.selecao_obrigatoria? then operador_ponto_de_acesso_path
        else operador_terminal_path
        end
      end

      def login_params
        params.expect(login_operador: [ :matricula, :password ])
      end
  end
end
