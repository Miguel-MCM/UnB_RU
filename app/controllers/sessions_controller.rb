class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.autenticar(params[:matricula], params[:password])

    if user
      reset_session
      session[:user_id] = user.id
      redirect_to recarga_path
    else
      flash.now[:alert] = "Matrícula ou senha inválidas."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Você saiu da sua conta."
  end
end
