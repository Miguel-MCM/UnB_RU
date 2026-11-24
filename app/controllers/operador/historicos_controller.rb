module Operador
  # Histórico local da catraca gerenciada pelo operador (<tt>/operador/historico</tt>).
  class HistoricosController < BaseController
    before_action :selecionar_catraca

    # GET /operador/historico: lista os acessos da catraca gerenciada.
    #
    # Argumentos:: <tt>params[:catraca_id]</tt> (opcional) troca a catraca
    #              gerenciada (ver BaseController#selecionar_catraca).
    # Retorno:: renderiza +historicos/show+ com +@catraca+ e +@acessos+ (do mais
    #           recente para o mais antigo). Sem catraca escolhida, a lista é
    #           vazia e a página avisa "Nenhuma catraca selecionada".
    # Efeitos colaterais:: pode gravar a catraca e o restaurante na sessão.
    def show
      @catraca = current_catraca
      @acessos = @catraca ? @catraca.acessos.recentes : Acesso.none
    end
  end
end
