class Extrato
  Lancamento = Data.define(:momento, :evento, :metodo, :valor_centavos) do
    def descricao
      evento == "recarga" ? "Recarga de Saldo" : Acesso::REFEICOES.fetch(evento, "Refeição")
    end

    def credito?
      valor_centavos.positive?
    end

    def valor_formatado
      "#{credito? ? "+" : "-"} #{ActiveSupport::NumberHelper.number_to_currency(valor_centavos.abs / 100.0)}"
    end
  end

  PERIODOS = %w[mes_atual 30_dias 90_dias tudo].freeze
  TIPOS = %w[todos cafe_da_manha almoco jantar recarga].freeze
  OPCOES_DE_TIPO = [
    [ "Todas as refeições e recargas", "todos" ],
    *Acesso::REFEICOES.map { |valor, nome| [ nome, valor ] },
    [ "Recarga de Saldo", "recarga" ]
  ].freeze

  attr_reader :periodo, :tipo

  def self.opcoes_de_periodo(agora = Time.current)
    mes = I18n.l(agora.to_date, format: "%B/%Y")

    [
      [ "Mês atual (#{mes})", "mes_atual" ],
      [ "Últimos 30 dias (#{mes})", "30_dias" ],
      [ "Últimos 90 dias", "90_dias" ],
      [ "Todo o histórico", "tudo" ]
    ]
  end

  def initialize(user, periodo: nil, tipo: nil, agora: Time.current)
    @user = user
    @agora = agora
    @periodo = periodo.presence_in(PERIODOS) || "mes_atual"
    @tipo = tipo.presence_in(TIPOS) || "todos"
  end

  def rotulo_do_periodo
    self.class.opcoes_de_periodo(@agora).rassoc(periodo).first
  end

  def rotulo_do_tipo
    OPCOES_DE_TIPO.rassoc(tipo).first
  end

  def total_gasto_no_mes
    refeicoes_do_mes.sum(:valor_centavos)
  end

  def debitos_no_mes
    refeicoes_do_mes.count
  end

  def refeicoes_no_mes
    refeicoes_do_mes.group(:refeicao).count
  end

  def total_recarregado_no_mes
    recargas_do_mes.sum(:valor_centavos)
  end

  def recargas_no_mes
    recargas_do_mes.count
  end

  def lancamentos
    (lancamentos_de_refeicao + lancamentos_de_recarga).sort_by(&:momento).reverse
  end

  private
    def inicio
      case periodo
      when "mes_atual" then @agora.beginning_of_month
      when "30_dias" then @agora - 30.days
      when "90_dias" then @agora - 90.days
      end
    end

    def no_periodo(escopo)
      inicio ? escopo.where(created_at: inicio..@agora) : escopo
    end

    def lancamentos_de_refeicao
      return [] if tipo == "recarga"

      escopo = no_periodo(@user.acessos.confirmado)
      escopo = escopo.where(refeicao: tipo) unless tipo == "todos"
      escopo.map do |acesso|
        Lancamento.new(momento: acesso.created_at, evento: acesso.refeicao, metodo: "QR Code",
                       valor_centavos: -acesso.valor_centavos)
      end
    end

    def lancamentos_de_recarga
      return [] unless tipo.in?(%w[todos recarga])

      no_periodo(@user.recargas).map do |recarga|
        Lancamento.new(momento: recarga.created_at, evento: "recarga",
                       metodo: Recarga::METODOS_PAGAMENTO[recarga.metodo_pagamento], valor_centavos: recarga.valor_centavos)
      end
    end

    def refeicoes_do_mes
      @user.acessos.confirmado.where(created_at: @agora.beginning_of_month..@agora)
    end

    def recargas_do_mes
      @user.recargas.where(created_at: @agora.beginning_of_month..@agora)
    end
end
