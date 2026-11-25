# Representa o valor unitário da refeição (em centavos) vigente no Restaurante Universitário.
class Tarifa < ApplicationRecord
  # Valor padrão da refeição (R$ 4,50) utilizado quando nenhuma tarifa foi cadastrada.
  PADRAO_CENTAVOS = 450

  validates :valor_centavos, numericality: { only_integer: true, greater_than: 0 }

  # Retorna o valor da tarifa mais recente cadastrada no banco ou o valor padrão.
  #
  # Argumentos:: nenhum.
  # Retorno:: +Integer+ com o valor da tarifa vigente em centavos.
  # Efeitos colaterais:: nenhum (realiza apenas consulta de leitura no banco).
  def self.vigente_centavos
    order(:id).last&.valor_centavos || PADRAO_CENTAVOS
  end
end
