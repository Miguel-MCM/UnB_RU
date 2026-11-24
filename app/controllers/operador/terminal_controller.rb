module Operador
  # Terminal de validação da catraca (<tt>/operador/terminal</tt>): leitor do
  # QR Code, resultado da última leitura e últimas validações.
  class TerminalController < BaseController
    # Quantidade de leituras exibidas em "Últimas Validações Registradas".
    ULTIMOS_ACESSOS = 8

    before_action :selecionar_catraca, :exigir_restaurante

    # GET /operador/terminal: mostra o terminal.
    #
    # Argumentos::
    #   <tt>params[:acesso]</tt> (opcional):: leitura cujo resultado é exibido;
    #   só vale para leituras do próprio operador.
    #   <tt>params[:catraca_id]</tt> (opcional):: troca a catraca gerenciada.
    # Retorno:: renderiza +terminal/show+ com +@acesso+ (+nil+ sem leitura ou
    #           com a leitura de outro operador), +@ultimos_acessos+ (os
    #           últimos da catraca gerenciada ou, sem catraca, do operador), o
    #           ponto de acesso e a tarifa vigente.
    # Efeitos colaterais:: pode gravar a catraca na sessão; sem restaurante
    #                      escolhido, redireciona para a seleção do ponto de acesso.
    def show
      @catraca = current_catraca
      @restaurante = current_restaurante
      @acesso = current_funcionario.acessos.includes(:user).find_by(id: params[:acesso])
      @ultimos_acessos = (@catraca || current_funcionario).acessos.recentes.limit(ULTIMOS_ACESSOS)
      @tarifa = Tarifa.vigente_centavos
    end
  end
end
