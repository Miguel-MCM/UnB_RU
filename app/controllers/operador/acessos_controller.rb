module Operador
  # Leitura da identificação do estudante no terminal de catraca
  # (<tt>POST /operador/acessos</tt>).
  class AcessosController < BaseController
    before_action :exigir_restaurante

    # POST /operador/acessos: registra a leitura da identificação, na entrada
    # comum ou na do FastPass.
    #
    # Argumentos::
    #   <tt>params[:identificacao]</tt>:: matrícula lida no QR Code.
    #   <tt>params[:modalidade]</tt>:: <tt>"fastpass"</tt> para a entrada do FastPass;
    #   ausente ou outro valor é a entrada comum.
    # Retorno:: redireciona para o terminal com o resultado da leitura
    #           (<tt>?acesso=</tt>); com a identificação em branco, redireciona
    #           para o terminal com o alerta "Informe a identificação do estudante.".
    # Efeitos colaterais:: grava o Acesso com Acesso.registrar_leitura!, sem
    #                      débito. Sem restaurante escolhido, #exigir_restaurante
    #                      redireciona para a seleção antes da leitura.
    def create
      if params[:identificacao].blank?
        return redirect_to operador_terminal_path, alert: "Informe a identificação do estudante."
      end

      acesso = Acesso.registrar_leitura!(params[:identificacao], modalidade: params[:modalidade], **ponto_de_acesso)
      redirect_to operador_terminal_path(acesso:)
    end

    private
      # Operador e local da leitura, a partir da sessão.
      #
      # Argumentos:: nenhum.
      # Retorno:: hash com +funcionario+, +restaurante+ e +catraca+ (os dois
      #           últimos podem ser +nil+).
      # Efeitos colaterais:: nenhum.
      def ponto_de_acesso
        { funcionario: current_funcionario, restaurante: current_restaurante, catraca: current_catraca }
      end
  end
end
