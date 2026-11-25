# Consolida indicadores mensais e lançamentos filtrados (refeições e recargas) de um estudante.
class Extrato
  # Representa uma linha individual (crédito ou débito) no extrato financeiro do estudante.
  Lancamento = Data.define(:momento, :evento, :metodo, :valor_centavos) do
    # Retorna a descrição legível do evento do lançamento.
    #
    # Argumentos:: nenhum.
    # Retorno:: +String+ com "Recarga de Saldo" ou o nome do turno da refeição.
    # Efeitos colaterais:: nenhum.
    def descricao
      evento == "recarga" ? "Recarga de Saldo" : Acesso::REFEICOES.fetch(evento, "Refeição")
    end

    # Indica se o lançamento representa entrada positiva de crédito.
    #
    # Argumentos:: nenhum.
    # Retorno:: +true+ para créditos (recargas); +false+ para débitos (refeições).
    # Efeitos colaterais:: nenhum.
    def credito?
      valor_centavos.positive?
    end

    # Formata o valor do lançamento com sinal (+ ou -) e moeda em reais.
    #
    # Argumentos:: nenhum.
    # Retorno:: +String+ formatada (ex.: "+ R$ 22,50" ou "- R$ 4,50").
    # Efeitos colaterais:: nenhum.
    def valor_formatado
      "#{credito? ? "+" : "-"} #{ActiveSupport::NumberHelper.number_to_currency(valor_centavos.abs / 100.0)}"
    end
  end

  # Identificadores válidos para filtro de período.
  PERIODOS = %w[mes_atual 30_dias 90_dias tudo].freeze

  # Identificadores válidos para filtro de tipo de lançamento.
  TIPOS = %w[todos cafe_da_manha almoco jantar recarga].freeze

  # Opções de seleção de tipo de lançamento para formulários e filtros.
  OPCOES_DE_TIPO = [
    [ "Todas as refeições e recargas", "todos" ],
    *Acesso::REFEICOES.map { |valor, nome| [ nome, valor ] },
    [ "Recarga de Saldo", "recarga" ]
  ].freeze

  # Filtro de período aplicado ao extrato (+mes_atual+, +30_dias+, +90_dias+ ou +tudo+).
  attr_reader :periodo

  # Filtro de tipo aplicado ao extrato (+todos+, +cafe_da_manha+, +almoco+, +jantar+ ou +recarga+).
  attr_reader :tipo

  # Gera a lista de opções de período com o nome do mês atual formatado.
  #
  # Argumentos::
  #   +agora+:: (+Time+, padrão +Time.current+) instante de referência.
  # Retorno:: +Array<Array<String>>+ contendo pares [rótulo, valor] para seleção.
  # Efeitos colaterais:: nenhum.
  def self.opcoes_de_periodo(agora = Time.current)
    mes = I18n.l(agora.to_date, format: "%B/%Y")

    [
      [ "Mês atual (#{mes})", "mes_atual" ],
      [ "Últimos 30 dias (#{mes})", "30_dias" ],
      [ "Últimos 90 dias", "90_dias" ],
      [ "Todo o histórico", "tudo" ]
    ]
  end

  # Inicializa o objeto de extrato aplicando valores padrão para filtros inválidos ou ausentes.
  #
  # Argumentos::
  #   +user+:: (+User+) estudante dono dos registros.
  #   +periodo+:: (+String+, opcional) filtro de período desejado.
  #   +tipo+:: (+String+, opcional) filtro de tipo desejado.
  #   +agora+:: (+Time+, padrão +Time.current+) data/hora de referência.
  # Retorno:: nova instância de +Extrato+.
  # Efeitos colaterais:: nenhum.
  def initialize(user, periodo: nil, tipo: nil, agora: Time.current)
    @user = user
    @agora = agora
    @periodo = periodo.presence_in(PERIODOS) || "mes_atual"
    @tipo = tipo.presence_in(TIPOS) || "todos"
  end

  # Retorna o rótulo legível correspondente ao período selecionado.
  #
  # Argumentos:: nenhum.
  # Retorno:: +String+ com o rótulo do período atual.
  # Efeitos colaterais:: nenhum.
  def rotulo_do_periodo
    self.class.opcoes_de_periodo(@agora).rassoc(periodo).first
  end

  # Retorna o rótulo legível correspondente ao tipo selecionado.
  #
  # Argumentos:: nenhum.
  # Retorno:: +String+ com o rótulo do tipo de lançamento selecionado.
  # Efeitos colaterais:: nenhum.
  def rotulo_do_tipo
    OPCOES_DE_TIPO.rassoc(tipo).first
  end

  # Soma o valor total gasto em refeições confirmadas no mês atual.
  #
  # Argumentos:: nenhum.
  # Retorno:: +Integer+ com o total gasto em centavos no mês corrente.
  # Efeitos colaterais:: nenhum.
  def total_gasto_no_mes
    refeicoes_do_mes.sum(:valor_centavos)
  end

  # Conta a quantidade de refeições confirmadas (débitos) no mês atual.
  #
  # Argumentos:: nenhum.
  # Retorno:: +Integer+ com o total de passagens confirmadas no mês.
  # Efeitos colaterais:: nenhum.
  def debitos_no_mes
    refeicoes_do_mes.count
  end

  # Agrupa e conta as refeições do mês atual por tipo de turno.
  #
  # Argumentos:: nenhum.
  # Retorno:: +Hash{String => Integer}+ mapeando cada tipo de refeição à sua quantidade.
  # Efeitos colaterais:: nenhum.
  def refeicoes_no_mes
    refeicoes_do_mes.group(:refeicao).count
  end

  # Soma o valor total recarregado no mês atual.
  #
  # Argumentos:: nenhum.
  # Retorno:: +Integer+ com o total recarregado em centavos no mês corrente.
  # Efeitos colaterais:: nenhum.
  def total_recarregado_no_mes
    recargas_do_mes.sum(:valor_centavos)
  end

  # Conta a quantidade de recargas efetuadas no mês atual.
  #
  # Argumentos:: nenhum.
  # Retorno:: +Integer+ com o número de recargas no mês corrente.
  # Efeitos colaterais:: nenhum.
  def recargas_no_mes
    recargas_do_mes.count
  end

  # Retorna a lista ordenada (do mais recente ao mais antigo) de lançamentos filtrados.
  #
  # Argumentos:: nenhum.
  # Retorno:: +Array<Lancamento>+ ordenada decrescentemente por +momento+.
  # Efeitos colaterais:: memoriza o resultado em +@lancamentos+.
  def lancamentos
    @lancamentos ||= (lancamentos_de_refeicao + lancamentos_de_recarga).sort_by(&:momento).reverse
  end

  # Verifica se não há lançamentos para os filtros aplicados.
  #
  # Argumentos:: nenhum.
  # Retorno:: +true+ se a lista de lançamentos estiver vazia; +false+ caso contrário.
  # Efeitos colaterais:: nenhum.
  def vazio?
    lancamentos.empty?
  end

  private
    # Calcula a data/hora inicial do filtro de período selecionado.
    #
    # Argumentos:: nenhum.
    # Retorno:: +Time+ com o início do intervalo ou +nil+ quando o período for +tudo+.
    # Efeitos colaterais:: nenhum.
    def inicio
      case periodo
      when "mes_atual" then @agora.beginning_of_month
      when "30_dias" then @agora - 30.days
      when "90_dias" then @agora - 90.days
      end
    end

    # Restringe um escopo ActiveRecord ao intervalo de datas selecionado, se houver.
    #
    # Argumentos::
    #   +escopo+:: (+ActiveRecord::Relation+) consulta base a ser filtrada.
    # Retorno:: +ActiveRecord::Relation+ filtrada ou inalterada.
    # Efeitos colaterais:: nenhum.
    def no_periodo(escopo)
      inicio ? escopo.where(created_at: inicio..@agora) : escopo
    end

    # Monta os lançamentos de débito referentes às refeições no período e tipo filtrados.
    #
    # Argumentos:: nenhum.
    # Retorno:: +Array<Lancamento>+ com os débitos encontrados ou +[]+ se tipo for +recarga+.
    # Efeitos colaterais:: nenhum.
    def lancamentos_de_refeicao
      return [] if tipo == "recarga"

      escopo_de_refeicoes.map { |acesso| acesso_para_lancamento(acesso) }
    end

    # Constrói o escopo de acessos confirmados do estudante dentro dos filtros ativos.
    #
    # Argumentos:: nenhum.
    # Retorno:: +ActiveRecord::Relation+ de +Acesso+ filtrada por período e tipo.
    # Efeitos colaterais:: nenhum.
    def escopo_de_refeicoes
      escopo = no_periodo(@user.acessos.confirmado)
      tipo == "todos" ? escopo : escopo.where(refeicao: tipo)
    end

    # Converte um registro de +Acesso+ em um objeto +Lancamento+ de débito.
    #
    # Argumentos::
    #   +acesso+:: (+Acesso+) acesso confirmado na catraca.
    # Retorno:: instância de +Lancamento+ com valor negativo.
    # Efeitos colaterais:: nenhum.
    def acesso_para_lancamento(acesso)
      Lancamento.new(
        momento: acesso.created_at,
        evento: acesso.refeicao,
        metodo: "QR Code",
        valor_centavos: -acesso.valor_centavos
      )
    end

    # Monta os lançamentos de crédito referentes às recargas no período filtrado.
    #
    # Argumentos:: nenhum.
    # Retorno:: +Array<Lancamento>+ com os créditos encontrados ou +[]+ quando filtrado por refeição.
    # Efeitos colaterais:: nenhum.
    def lancamentos_de_recarga
      return [] unless tipo.in?(%w[todos recarga])

      no_periodo(@user.recargas).map do |recarga|
        Lancamento.new(momento: recarga.created_at, evento: "recarga",
                       metodo: Recarga::METODOS_PAGAMENTO[recarga.metodo_pagamento], valor_centavos: recarga.valor_centavos)
      end
    end

    # Retorna os acessos confirmados do estudante no mês corrente.
    #
    # Argumentos:: nenhum.
    # Retorno:: +ActiveRecord::Relation+ de +Acesso+.
    # Efeitos colaterais:: nenhum.
    def refeicoes_do_mes
      @user.acessos.confirmado.where(created_at: @agora.beginning_of_month..@agora)
    end

    # Retorna as recargas do estudante no mês corrente.
    #
    # Argumentos:: nenhum.
    # Retorno:: +ActiveRecord::Relation+ de +Recarga+.
    # Efeitos colaterais:: nenhum.
    def recargas_do_mes
      @user.recargas.where(created_at: @agora.beginning_of_month..@agora)
    end
end
