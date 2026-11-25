# Relatório global de acessos: aplica os filtros (restaurante e catraca) e o agrupamento
# escolhidos pelo administrador sobre os registros de +Acesso+.
#
# Não é persistido; reúne uma regra que envolve +Restaurante+, +Catraca+ e +Acesso+.
# Quando o filtro é inconsistente (catraca de outro restaurante) o relatório fica vazio e
# #erro traz a mensagem para o usuário.
class RelatorioAcessos
  # Agrupamentos aceitos: tabela a juntar e coluna a agrupar, por nome.
  GRUPOS = {
    "restaurante" => { juncao: :restaurante, coluna: "restaurantes.nome" },
    "catraca" => { juncao: :catraca, coluna: "catracas.nome" }
  }.freeze

  # Mensagem de erro de filtro (+String+) ou +nil+ quando o filtro é consistente.
  attr_reader :erro
  # Restaurante filtrado (+Restaurante+ ou +nil+).
  attr_reader :restaurante

  # Monta o relatório e já aplica os filtros.
  #
  # Argumentos::
  #   +restaurante_nome+ (String ou +nil+):: nome exato do restaurante; vazio não filtra.
  #   +catraca_nome+ (String ou +nil+):: nome exato da catraca; vazio não filtra.
  #   +agrupar_por+ (String ou +nil+):: <tt>"restaurante"</tt> ou <tt>"catraca"</tt>;
  #                                    outros valores não agrupam.
  # Retorno:: a nova instância.
  # Efeitos colaterais:: consultas de leitura ao banco; nada é gravado.
  def initialize(restaurante_nome: nil, catraca_nome: nil, agrupar_por: nil)
    @restaurante_nome = restaurante_nome.presence
    @catraca_nome = catraca_nome.presence
    @agrupar_por = agrupar_por
    @acessos = Acesso.includes(:restaurante, :catraca, :user).order(created_at: :desc)
    filtrar_restaurante
    filtrar_catraca
  end

  # Acessos do relatório, do mais recente para o mais antigo.
  #
  # Argumentos:: nenhum.
  # Retorno:: +ActiveRecord::Relation+ de +Acesso+; vazia quando o filtro não casa com
  #           nada ou é inconsistente.
  # Efeitos colaterais:: nenhum.
  def acessos
    @acessos
  end

  # Indica se há algo para exportar.
  #
  # Argumentos:: nenhum.
  # Retorno:: +true+ quando não há acessos no filtro; +false+ caso contrário.
  # Efeitos colaterais:: uma consulta +EXISTS+ ao banco.
  def vazio?
    @acessos.empty?
  end

  # Motivo pelo qual o relatório não pode ser exportado em PDF.
  #
  # Argumentos:: nenhum.
  # Retorno:: a mensagem de #erro; <tt>"Não há dados para exportar"</tt> quando está
  #           vazio; ou +nil+ quando a exportação é possível.
  # Efeitos colaterais:: uma consulta +EXISTS+ ao banco quando não há erro.
  def impedimento_de_exportacao
    erro.presence || ("Não há dados para exportar" if vazio?)
  end

  # Total de acessos por restaurante ou por catraca, conforme +agrupar_por+.
  #
  # Argumentos:: nenhum.
  # Retorno:: +Hash+ <tt>{ nome => total }</tt>, ou +nil+ quando não há agrupamento
  #           válido ou o filtro deu erro.
  # Efeitos colaterais:: uma consulta de contagem ao banco.
  def totais_agrupados
    grupo = GRUPOS[@agrupar_por]
    return if grupo.nil? || erro

    @totais_agrupados ||= @acessos.reorder(nil).joins(grupo[:juncao]).group(grupo[:coluna]).count
  end

  private
    # Restringe aos acessos do restaurante nomeado (nenhum, se ele não existe).
    # Efeitos colaterais:: define +@restaurante+ e reduz +@acessos+.
    def filtrar_restaurante
      return unless @restaurante_nome

      @restaurante = Restaurante.find_by(nome: @restaurante_nome)
      @acessos = @restaurante ? @acessos.where(restaurante_id: @restaurante.id) : Acesso.none
    end

    # Restringe aos acessos da catraca nomeada, dentro do restaurante quando há um.
    # Efeitos colaterais:: reduz +@acessos+; define +@erro+ quando a catraca existe mas
    #                      pertence a outro restaurante.
    def filtrar_catraca
      return unless @catraca_nome

      catraca = catracas_do_filtro.find_by(nome: @catraca_nome)
      if catraca.nil? && @restaurante && Catraca.exists?(nome: @catraca_nome)
        @erro = "A catraca #{@catraca_nome} não pertence ao restaurante #{@restaurante.nome}"
      end
      @acessos = catraca && !@erro ? @acessos.where(catraca_id: catraca.id) : Acesso.none
    end

    # Catracas em que a busca por nome vale: as do restaurante filtrado ou todas.
    def catracas_do_filtro
      @restaurante ? @restaurante.catracas : Catraca
    end
end
