class Acesso < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :funcionario
  belongs_to :restaurante, optional: true
  belongs_to :catraca, optional: true

  enum :status, {
    liberado: "liberado",
    confirmado: "confirmado",
    saldo_insuficiente: "saldo_insuficiente",
    nao_encontrado: "nao_encontrado"
  }

  validates :identificacao, presence: true

  before_validation :sincronizar_restaurante_da_catraca

  def self.registrar_leitura!(identificacao, funcionario:, restaurante: nil, catraca: nil)
    identificacao = identificacao.to_s.strip
    user = User.find_by(matricula: identificacao)
    tarifa = Tarifa.vigente_centavos

    status =
      if user.nil? then :nao_encontrado
      elsif user.saldo_centavos < tarifa then :saldo_insuficiente
      else :liberado
      end

    create!(
      identificacao:,
      user:,
      funcionario:,
      restaurante: restaurante || catraca&.restaurante,
      catraca:,
      valor_centavos: tarifa,
      status:
    )
  end

  def liberou_catraca?
    liberado? || confirmado?
  end

  def confirmar_passagem!
    with_lock do
      next false unless liberado?

      user.with_lock do
        if user.saldo_centavos < valor_centavos
          saldo_insuficiente!
          next false
        end

        user.update!(saldo_centavos: user.saldo_centavos - valor_centavos)
        confirmado!
        true
      end
    end
  end

  private
    def sincronizar_restaurante_da_catraca
      self.restaurante ||= catraca&.restaurante
    end
end
