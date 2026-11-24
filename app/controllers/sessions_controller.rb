# Login e logout do estudante no Portal do Estudante (<tt>/login</tt>).
class SessionsController < ApplicationController
  # GET /login: formulário de login do estudante.
  #
  # Argumentos:: nenhum.
  # Retorno:: renderiza +sessions/new+.
  # Efeitos colaterais:: nenhum.
  def new
  end

  # POST /login: autentica o estudante pela matrícula e senha.
  #
  # Argumentos:: <tt>params[:matricula]</tt> e <tt>params[:password]</tt>.
  # Retorno:: com credenciais válidas, redireciona para a recarga; com
  #           credenciais inválidas ou campos vazios, renderiza o formulário
  #           com status 422 e o alerta "Matrícula ou senha inválidas.".
  # Efeitos colaterais:: no sucesso, recria a sessão (+reset_session+, que
  #                      também encerra qualquer login de operador) e grava
  #                      <tt>session[:user_id]</tt>.
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

  # DELETE /logout: encerra a sessão do estudante.
  #
  # Argumentos:: nenhum.
  # Retorno:: redireciona para <tt>/login</tt> com o aviso "Você saiu da sua conta.".
  # Efeitos colaterais:: apaga a sessão inteira (+reset_session+).
  def destroy
    reset_session
    redirect_to login_path, notice: "Você saiu da sua conta."
  end
end
