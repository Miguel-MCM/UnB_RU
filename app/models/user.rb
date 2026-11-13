class User < ApplicationRecord
  has_many :recargas, dependent: :destroy

  normalizes :matricula, with: ->(matricula) { matricula.strip }

  validates :nome, presence: true
  validates :matricula, presence: true, uniqueness: true, format: { with: /\A\d+\z/, allow_blank: true }
  validates :password, presence: true, confirmation: true

  def self.autenticar(matricula, password)
    user = find_by(matricula: matricula.to_s.strip)
    user if user && ActiveSupport::SecurityUtils.secure_compare(user.password, password.to_s)
  end

  def refeicoes_disponiveis
    saldo_centavos / Recarga::TARIFA_CENTAVOS
  end

  def recarregar!(quantidade:, metodo_pagamento:)
    transaction do
      recarga = recargas.create!(quantidade:, metodo_pagamento:)
      increment!(:saldo_centavos, recarga.valor_centavos)
      recarga
    end
  end
end
