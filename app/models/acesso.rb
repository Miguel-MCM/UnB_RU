class Acesso < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :funcionario
  belongs_to :restaurante, optional: true
  belongs_to :catraca, optional: true
  belongs_to :inscricao_fastpass, optional: true

  enum :status, {
    liberado: "liberado",
    confirmado: "confirmado",
    saldo_insuficiente: "saldo_insuficiente",
    nao_encontrado: "nao_encontrado",
    fora_do_time_frame: "fora_do_time_frame",
    sem_fastpass: "sem_fastpass",
    fastpass_utilizado: "fastpass_utilizado"
  }

  enum :modalidade, { comum: "comum", fastpass: "fastpass" }, prefix: true

  REFEICOES = { "cafe_da_manha" => "Café da Manhã", "almoco" => "Almoço", "jantar" => "Jantar" }.freeze

  validates :identificacao, presence: true
  validate :catraca_do_restaurante

  before_validation :sincronizar_restaurante_da_catraca

  def self.refeicao_do_horario(momento)
    minutos = HorarioEmMinutos.minutos_do(momento)

    if minutos < 10 * 60 + 30 then "cafe_da_manha"
    elsif minutos < 16 * 60 then "almoco"
    else "jantar"
    end
  end

  # Registra a leitura da identificação na entrada comum ou na do FastPass. Só
  # libera a catraca; o débito acontece em #confirmar_passagem!.
  def self.registrar_leitura!(identificacao, funcionario:, restaurante: nil, catraca: nil, modalidade: "comum")
    identificacao = identificacao.to_s.strip
    user = User.find_by(matricula: identificacao)
    tarifa = Tarifa.vigente_centavos
    restaurante ||= catraca&.restaurante

    status, inscricao_fastpass =
      if modalidade.to_s == "fastpass"
        status_do_fastpass(user, restaurante, tarifa)
      else
        [ status_da_entrada_comum(user, tarifa), nil ]
      end

    create!(
      identificacao:,
      user:,
      funcionario:,
      restaurante:,
      catraca:,
      valor_centavos: tarifa,
      status:,
      modalidade:,
      inscricao_fastpass:,
      refeicao: refeicao_do_horario(Time.current)
    )
  end

  def self.status_da_entrada_comum(user, tarifa)
    if user.nil? then :nao_encontrado
    elsif user.saldo_centavos < tarifa then :saldo_insuficiente
    else :liberado
    end
  end
  private_class_method :status_da_entrada_comum

  # Retorna o status da leitura no FastPass e a inscrição contemplada encontrada
  # (gravada no acesso para auditoria, mesmo quando a entrada é bloqueada).
  def self.status_do_fastpass(user, restaurante, tarifa)
    return [ :nao_encontrado, nil ] if user.nil?

    momento = Time.current
    inscricao = InscricaoFastpass.contemplada_de(user, restaurante, momento)

    status =
      if inscricao.nil? then :sem_fastpass
      elsif inscricao.utilizado? then :fastpass_utilizado
      elsif !inscricao.time_frame.cobre?(HorarioEmMinutos.minutos_do(momento)) then :fora_do_time_frame
      elsif user.saldo_centavos < tarifa then :saldo_insuficiente
      else :liberado
      end

    [ status, inscricao ]
  end
  private_class_method :status_do_fastpass

  def liberou_catraca?
    liberado? || confirmado?
  end

  def confirmar_passagem!
    with_lock do
      next false unless liberado?

      if inscricao_fastpass
        inscricao_fastpass.lock!
        unless inscricao_fastpass.sorteado?
          inscricao_fastpass.utilizado? ? fastpass_utilizado! : sem_fastpass!
          next false
        end
      end

      user.with_lock do
        if user.saldo_centavos < valor_centavos
          saldo_insuficiente!
          next false
        end

        user.update!(saldo_centavos: user.saldo_centavos - valor_centavos)
        inscricao_fastpass&.utilizado!
        confirmado!
        true
      end
    end
  end

  private
    def sincronizar_restaurante_da_catraca
      self.restaurante ||= catraca&.restaurante
    end

    def catraca_do_restaurante
      return if catraca.nil? || restaurante_id.nil?

      errors.add(:catraca, :restaurante_divergente) if catraca.restaurante_id != restaurante_id
    end
end
