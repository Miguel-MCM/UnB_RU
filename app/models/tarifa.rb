class Tarifa < ApplicationRecord
  PADRAO_CENTAVOS = 450

  validates :valor_centavos, numericality: { only_integer: true, greater_than: 0 }

  def self.vigente_centavos
    order(:id).last&.valor_centavos || PADRAO_CENTAVOS
  end
end
