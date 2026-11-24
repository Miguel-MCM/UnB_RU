module Operador
  # Login e logout do funcionário na Aplicação de Controle (<tt>/operador/login</tt>).
  class SessionsController < BaseController
    skip_before_action :require_operador

    # GET /operador/login: formulário de autenticação do operador.
    #
    # Argumentos:: nenhum.
    # Retorno:: renderiza +sessions/new+ com um LoginOperador vazio.
    # Efeitos colaterais:: nenhum.
    def new
      @login = LoginOperador.new
    end

    # POST /operador/login: autentica o funcionário.
    #
    # Argumentos:: <tt>params[:login_operador]</tt> com +matricula+ e +password+.
    # Retorno:: com credenciais válidas, redireciona para o destino de
    #           #destino_apos_login. Com campos em branco, renderiza o
    #           formulário com status 422 e "Campo obrigatório" nos campos; com
    #           credenciais erradas, status 422 e o alerta "Matrícula ou senha
    #           inválidas.".
    # Efeitos colaterais:: no sucesso, recria a sessão (+reset_session+, que
    #                      também encerra o login de estudante e o ponto de
    #                      acesso anterior) e grava <tt>session[:funcionario_id]</tt>.
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

    # DELETE /operador/logout: encerra a sessão do operador.
    #
    # Argumentos:: nenhum.
    # Retorno:: redireciona para <tt>/operador/login</tt> com o aviso "Sessão do operador encerrada.".
    # Efeitos colaterais:: apaga a sessão inteira (+reset_session+).
    def destroy
      reset_session
      redirect_to operador_login_path, notice: "Sessão do operador encerrada."
    end

    private
      # Primeira tela depois do login.
      #
      # Argumentos:: +funcionario+ (Funcionario): quem acabou de entrar.
      # Retorno:: o caminho da gestão de restaurantes para administradores; o da
      #           seleção do ponto de acesso quando há restaurantes cadastrados;
      #           ou o do terminal.
      # Efeitos colaterais:: nenhum.
      def destino_apos_login(funcionario)
        if funcionario.administrador? then admin_restaurantes_path
        elsif Restaurante.selecao_obrigatoria? then operador_ponto_de_acesso_path
        else operador_terminal_path
        end
      end

      # Parâmetros permitidos do login.
      #
      # Argumentos:: nenhum; lê <tt>params[:login_operador]</tt>.
      # Retorno:: hash com +matricula+ e +password+.
      # Efeitos colaterais:: responde 400 (Bad Request) quando o parâmetro não
      #                      vem no formato esperado.
      def login_params
        params.expect(login_operador: [ :matricula, :password ])
      end
  end
end
