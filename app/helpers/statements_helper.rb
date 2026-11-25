# Helpers de formatação de textos, frequências e datas na página de extrato do estudante.
module StatementsHelper
  # Formas singular e plural dos tipos de refeição para exibição da frequência mensal.
  REFEICOES_NO_PLURAL = { "almoco" => %w[almoço almoços], "jantar" => %w[jantar jantares], "cafe_da_manha" => %w[café cafés] }.freeze

  # Formata o resumo textual da frequência de refeições realizadas no mês.
  #
  # Argumentos::
  #   +refeicoes+:: (+Hash{String => Integer}+) contagem de refeições agrupadas por turno.
  # Retorno:: +String+ descrevendo as quantidades por turno ou "Nenhuma refeição no mês".
  # Efeitos colaterais:: nenhum.
  def frequencia_de_refeicoes(refeicoes)
    partes = REFEICOES_NO_PLURAL.filter_map do |refeicao, (singular, plural)|
      quantidade = refeicoes[refeicao].to_i
      pluralize(quantidade, singular, plural:) if quantidade.positive?
    end

    partes.any? ? partes.join(" · ") : "Nenhuma refeição no mês"
  end

  # Formata a linha de resumo de débitos exibida no card de gastos do mês.
  #
  # Argumentos::
  #   +quantidade+:: (+Integer+) número total de débitos no mês.
  #   +total_centavos+:: (+Integer+) soma total gasta em centavos no mês.
  # Retorno:: +String+ com a quantidade de débitos e o valor unitário quando exato.
  # Efeitos colaterais:: nenhum.
  def resumo_de_debitos(quantidade, total_centavos)
    texto = pluralize(quantidade, "débito", plural: "débitos")
    return texto unless quantidade.positive? && (total_centavos % quantidade).zero?

    "#{texto} de #{reais(total_centavos / quantidade)}"
  end

  # Formata a data e hora principal de um lançamento usando rótulos relativos ("Hoje", "Ontem").
  #
  # Argumentos::
  #   +momento+:: (+Time+) data e hora do lançamento.
  # Retorno:: +String+ formatada de forma amigável para o usuário.
  # Efeitos colaterais:: nenhum.
  def momento_do_lancamento(momento)
    dia = momento.to_date

    if dia == Date.current then "Hoje, #{l(momento, format: "%H:%M")}"
    elsif dia == Date.yesterday then "Ontem, #{l(momento, format: "%H:%M")}"
    else l(momento, format: "%d/%m/%Y, %H:%M")
    end
  end

  # Formata a legenda complementar da data de um lançamento (data completa ou dia da semana).
  #
  # Argumentos::
  #   +momento+:: (+Time+) data e hora do lançamento.
  # Retorno:: +String+ com a data por extenso (para hoje/ontem) ou o dia da semana.
  # Efeitos colaterais:: nenhum.
  def detalhe_do_lancamento(momento)
    dia = momento.to_date
    dia >= Date.yesterday ? l(dia, format: "%-d de %B de %Y") : l(dia, format: "%A")
  end
end
