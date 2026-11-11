module Operador
  class SessionsController < ApplicationController
    layout "operador"

    def new
      @login = LoginOperador.new
    end

    def create
      @login = LoginOperador.new(login_params)

      if (funcionario = @login.funcionario)
        reset_session
        session[:funcionario_id] = funcionario.id
        redirect_to operador_terminal_path
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
      def login_params
        params.expect(login_operador: [ :matricula, :password ])
      end
  end
end
