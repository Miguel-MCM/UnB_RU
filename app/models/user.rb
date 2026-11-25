# Representa um estudante cadastrado no sistema do RU UnB, com controle de saldo e acessos.
class User < ApplicationRecord
  include Autenticavel

  has_many :recargas, dependent: :destroy
  has_many :acessos, dependent: :nullify
  has_many :inscricoes_fastpass, dependent: :destroy
  has_many :notificacoes, dependent: :destroy

  normalizes :matricula, with: ->(matricula) { matricula.strip }

  validates :nome, presence: true
  validates :matricula, presence: true, uniqueness: true, format: { with: /\A\d+\z/, allow_blank: true }
  validates :password, presence: true, confirmation: true

  # Calcula quantas refeições inteiras o estudante consegue pagar com o saldo atual.
  #
  # Argumentos:: nenhum.
  # Retorno:: +Integer+ com a quantidade de refeições disponíveis segundo a tarifa vigente.
  # Efeitos colaterais:: nenhum.
  def refeicoes_disponiveis
    saldo_centavos / Tarifa.vigente_centavos
  end

  # Registra uma nova recarga e credita o valor correspondente no saldo do estudante.
  #
  # Argumentos::
  #   +quantidade+:: (+Integer+ ou +String+) número de refeições compradas na recarga.
  #   +metodo_pagamento+:: (+String+) meio de pagamento utilizado (+pix+ ou +cartao+).
  # Retorno:: instância persistida de +Recarga+ em caso de sucesso;
  #           lança +ActiveRecord::RecordInvalid+ se a validação da recarga falhar.
  # Efeitos colaterais:: dentro de uma transação no banco de dados, cria um registro
  #                      em +recargas+ e incrementa +saldo_centavos+ do usuário.
  def recarregar!(quantidade:, metodo_pagamento:)
    transaction do
      recarga = recargas.create!(quantidade:, metodo_pagamento:)
      increment!(:saldo_centavos, recarga.valor_centavos)
      recarga
    end
  end
end
