module Admin
  # Ajuste do horário do sistema pelo administrador, para demonstrações e testes
  # manuais. Só existe quando o ajuste está ligado (ver Relogio.ajustavel?).
  class RelogiosController < BaseController
    before_action :exigir_relogio_ajustavel
    before_action :carregar_relogio

    # GET /admin/relogio: mostra o horário do sistema e o formulário de ajuste.
    #
    # Argumentos:: nenhum.
    # Retorno:: renderiza +admin/relogios/show+ com +@relogio+.
    # Efeitos colaterais:: pode criar o registro do relógio.
    def show
    end

    # PATCH /admin/relogio: ajusta o horário do sistema.
    #
    # Argumentos:: <tt>params[:relogio][:horario_simulado]</tt>.
    # Retorno:: redireciona para a tela do relógio com aviso, ou reexibe o
    #           formulário com status 422 quando o horário é inválido.
    # Efeitos colaterais:: grava o deslocamento do relógio (ver Relogio#ajustar_para).
    def update
      if @relogio.ajustar_para(params.expect(relogio: [ :horario_simulado ])[:horario_simulado])
        redirect_to admin_relogio_path, notice: "Horário do sistema ajustado."
      else
        flash.now[:alert] = @relogio.errors.full_messages.to_sentence
        render :show, status: :unprocessable_content
      end
    end

    # PATCH /admin/relogio/deslocar: avança ou atrasa o horário em meia hora
    # (setas + e − ao lado do relógio do terminal).
    #
    # Argumentos:: <tt>params[:sentido]</tt>: <tt>"mais"</tt> ou <tt>"menos"</tt>.
    # Retorno:: volta à página de origem (ou à tela do relógio); responde 400
    #           para um sentido desconhecido.
    # Efeitos colaterais:: altera o deslocamento do relógio (ver Relogio#deslocar!).
    def deslocar
      @relogio.deslocar!(params.expect(:sentido))
      redirect_back_or_to admin_relogio_path
    rescue KeyError
      head :bad_request
    end

    # DELETE /admin/relogio: volta ao horário real.
    #
    # Argumentos:: nenhum.
    # Retorno:: redireciona para a tela do relógio com aviso.
    # Efeitos colaterais:: zera o deslocamento do relógio.
    def destroy
      @relogio.restaurar!
      redirect_to admin_relogio_path, notice: "Horário real restaurado."
    end

    private
      def exigir_relogio_ajustavel
        head :not_found unless Relogio.ajustavel?
      end

      def carregar_relogio
        @relogio = Relogio.atual
      end
  end
end
