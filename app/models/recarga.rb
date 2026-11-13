class Recarga < ApplicationRecord
  METODOS_PAGAMENTO = { "pix" => "PIX Instantâneo", "cartao" => "Cartão de Crédito" }.freeze
  PACOTES = { 2 => nil, 5 => "1 semana", 10 => "2 semanas", 20 => "Mensal" }.freeze

  belongs_to :user

  validates :quantidade, numericality: { only_integer: true, greater_than: 0 }
  validates :metodo_pagamento, inclusion: { in: METODOS_PAGAMENTO.keys }

  before_validation { self.valor_centavos = quantidade.to_i * Tarifa.vigente_centavos }
end
