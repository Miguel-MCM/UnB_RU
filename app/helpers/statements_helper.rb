module StatementsHelper
  REFEICOES_NO_PLURAL = { "almoco" => %w[almoço almoços], "jantar" => %w[jantar jantares], "cafe_da_manha" => %w[café cafés] }.freeze

  def frequencia_de_refeicoes(refeicoes)
    partes = REFEICOES_NO_PLURAL.filter_map do |refeicao, (singular, plural)|
      quantidade = refeicoes[refeicao].to_i
      pluralize(quantidade, singular, plural:) if quantidade.positive?
    end

    partes.any? ? partes.join(" · ") : "Nenhuma refeição no mês"
  end

  def resumo_de_debitos(quantidade, total_centavos)
    texto = pluralize(quantidade, "débito", plural: "débitos")
    return texto unless quantidade.positive? && (total_centavos % quantidade).zero?

    "#{texto} de #{reais(total_centavos / quantidade)}"
  end

  def momento_do_lancamento(momento)
    dia = momento.to_date

    if dia == Date.current then "Hoje, #{l(momento, format: "%H:%M")}"
    elsif dia == Date.yesterday then "Ontem, #{l(momento, format: "%H:%M")}"
    else l(momento, format: "%d/%m/%Y, %H:%M")
    end
  end

  def detalhe_do_lancamento(momento)
    dia = momento.to_date
    dia >= Date.yesterday ? l(dia, format: "%-d de %B de %Y") : l(dia, format: "%A")
  end
end
