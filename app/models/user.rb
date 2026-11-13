class User < ApplicationRecord
  include Autenticavel

  has_many :recargas, dependent: :destroy
  has_many :acessos, dependent: :nullify

  normalizes :matricula, with: ->(matricula) { matricula.strip }

  validates :nome, presence: true
  validates :matricula, presence: true, uniqueness: true, format: { with: /\A\d+\z/, allow_blank: true }
  validates :password, presence: true, confirmation: true

  def refeicoes_disponiveis
    saldo_centavos / Tarifa.vigente_centavos
  end

  def recarregar!(quantidade:, metodo_pagamento:)
    transaction do
      recarga = recargas.create!(quantidade:, metodo_pagamento:)
      increment!(:saldo_centavos, recarga.valor_centavos)
      recarga
    end
  end
end
