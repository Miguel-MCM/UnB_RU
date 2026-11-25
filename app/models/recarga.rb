# Registra uma operação de recarga de créditos (em refeições) na conta de um estudante.
class Recarga < ApplicationRecord
  # Métodos de pagamento aceitos na recarga e seus rótulos de exibição.
  METODOS_PAGAMENTO = { "pix" => "PIX Instantâneo", "cartao" => "Cartão de Crédito" }.freeze

  # Pacotes pré-definidos de quantidade de refeições e seus subtítulos opcionais.
  PACOTES = { 2 => nil, 5 => "1 semana", 10 => "2 semanas", 20 => "Mensal" }.freeze

  belongs_to :user

  validates :quantidade, numericality: { only_integer: true, greater_than: 0 }
  validates :metodo_pagamento, inclusion: { in: METODOS_PAGAMENTO.keys }

  before_validation :calcular_valor_centavos

  private
    # Calcula e atribui o valor total da recarga em centavos com base na tarifa vigente.
    #
    # Argumentos:: nenhum.
    # Retorno:: +Integer+ com o valor calculado em centavos.
    # Efeitos colaterais:: altera o atributo +valor_centavos+ do registro em memória.
    def calcular_valor_centavos
      self.valor_centavos = quantidade.to_i * Tarifa.vigente_centavos
    end
end
