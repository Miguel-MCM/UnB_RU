# Cadastro do estudante no Portal do Estudante (<tt>/cadastro</tt>).
class UsersController < ApplicationController
  # GET /cadastro: formulário de cadastro.
  #
  # Argumentos:: nenhum.
  # Retorno:: renderiza +users/new+ com um User vazio.
  # Efeitos colaterais:: nenhum.
  def new
    @user = User.new
  end

  # POST /cadastro: cria a conta do estudante.
  #
  # Argumentos:: <tt>params[:user]</tt> com +nome+, +matricula+, +password+ e
  #              +password_confirmation+ (ver #user_params).
  # Retorno:: com dados válidos, redireciona para <tt>/login</tt> com a
  #           confirmação do cadastro; com dados inválidos (campos em branco,
  #           matrícula repetida ou não numérica, senhas que não conferem),
  #           renderiza o formulário com status 422 e os erros nos campos.
  # Efeitos colaterais:: no sucesso, grava o User com saldo zero. Não inicia
  #                      a sessão: o estudante entra pelo login.
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to login_path, notice: "Conta criada com sucesso! Acesse com sua matrícula e senha."
    else
      render :new, status: :unprocessable_content
    end
  end

  private
    # Parâmetros permitidos do cadastro.
    #
    # Argumentos:: nenhum; lê <tt>params[:user]</tt>.
    # Retorno:: hash com +nome+, +matricula+, +password+ e +password_confirmation+.
    # Efeitos colaterais:: responde 400 (Bad Request) quando <tt>params[:user]</tt>
    #                      não vem no formato esperado.
    def user_params
      params.expect(user: [ :nome, :matricula, :password, :password_confirmation ])
    end
end
