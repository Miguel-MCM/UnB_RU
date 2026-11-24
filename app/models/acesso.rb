# Uma leitura da identificação de um estudante na catraca, feita por um
# operador (Funcionario) num ponto de acesso (restaurante e, opcionalmente,
# catraca), na entrada comum ou na do FastPass.
#
# A leitura só libera a catraca (status +liberado+) ou registra o motivo do
# bloqueio; o débito da refeição acontece depois, em #confirmar_passagem!,
# quando o estudante passa. O valor debitado é a tarifa vigente no momento da
# leitura, guardada em +valor_centavos+.
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

  # Nome de exibição de cada refeição registrada em +refeicao+.
  REFEICOES = { "cafe_da_manha" => "Café da Manhã", "almoco" => "Almoço", "jantar" => "Jantar" }.freeze

  validates :identificacao, presence: true
  validate :catraca_do_restaurante

  scope :recentes, -> { includes(:user).order(created_at: :desc, id: :desc) }

  before_validation :sincronizar_restaurante_da_catraca

  # Classifica um horário na refeição do dia: café da manhã antes das 10:30,
  # almoço até as 16:00 e jantar depois disso.
  #
  # Argumentos:: +momento+ (Time): horário da leitura.
  # Retorno:: <tt>"cafe_da_manha"</tt>, <tt>"almoco"</tt> ou <tt>"jantar"</tt>.
  # Efeitos colaterais:: nenhum.
  def self.refeicao_do_horario(momento)
    minutos = HorarioEmMinutos.minutos_do(momento)

    if minutos < 10 * 60 + 30 then "cafe_da_manha"
    elsif minutos < 16 * 60 then "almoco"
    else "jantar"
    end
  end

  # Registra a leitura da identificação de um estudante na entrada comum ou na
  # do FastPass. Só decide se a catraca é liberada; o débito acontece em
  # #confirmar_passagem!.
  #
  # Argumentos::
  #   +identificacao+ (String):: matrícula lida no QR Code; espaços nas pontas são ignorados.
  #   +funcionario+ (Funcionario):: operador que fez a leitura.
  #   +restaurante+ (Restaurante, opcional):: ponto de acesso; quando +nil+, vem da catraca.
  #   +catraca+ (Catraca, opcional):: catraca em que a leitura foi feita.
  #   +modalidade+ (String ou Symbol):: <tt>"comum"</tt> ou <tt>"fastpass"</tt>; qualquer
  #   outro valor é tratado como <tt>"comum"</tt>.
  # Retorno:: o Acesso criado, com status +liberado+ ou com o motivo do bloqueio
  #           (+nao_encontrado+, +saldo_insuficiente+, +sem_fastpass+,
  #           +fastpass_utilizado+ ou +fora_do_time_frame+).
  # Efeitos colaterais:: grava o acesso com a tarifa vigente, a refeição do
  #                      horário e, no FastPass, a inscrição encontrada. Não
  #                      altera o saldo. Levanta ActiveRecord::RecordInvalid se
  #                      a identificação vier vazia ou a catraca for de outro
  #                      restaurante.
  def self.registrar_leitura!(identificacao, funcionario:, restaurante: nil, catraca: nil, modalidade: "comum")
    identificacao = identificacao.to_s.strip
    user = User.find_by(matricula: identificacao)
    tarifa = Tarifa.vigente_centavos
    restaurante ||= catraca&.restaurante
    modalidade = modalidade_da_leitura(modalidade)

    status, inscricao_fastpass =
      if modalidade == "fastpass"
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

  # Normaliza a modalidade recebida do terminal.
  #
  # Argumentos:: +modalidade+ (String, Symbol ou +nil+).
  # Retorno:: <tt>"fastpass"</tt> quando é essa a modalidade pedida; <tt>"comum"</tt>
  #           para <tt>"comum"</tt>, valores vazios ou desconhecidos.
  # Efeitos colaterais:: nenhum.
  def self.modalidade_da_leitura(modalidade)
    modalidade.to_s.presence_in(modalidades.keys) || "comum"
  end
  private_class_method :modalidade_da_leitura

  # Decide o status de uma leitura na entrada comum.
  #
  # Argumentos::
  #   +user+ (User ou +nil+):: estudante da identificação lida.
  #   +tarifa+ (Integer):: tarifa vigente, em centavos.
  # Retorno:: +:nao_encontrado+ sem estudante, +:saldo_insuficiente+ quando o
  #           saldo é menor que a tarifa, ou +:liberado+.
  # Efeitos colaterais:: nenhum.
  def self.status_da_entrada_comum(user, tarifa)
    if user.nil? then :nao_encontrado
    elsif user.saldo_centavos < tarifa then :saldo_insuficiente
    else :liberado
    end
  end
  private_class_method :status_da_entrada_comum

  # Decide o status de uma leitura na entrada do FastPass e encontra a
  # inscrição contemplada do estudante, que é gravada no acesso para
  # auditoria mesmo quando a entrada é bloqueada.
  #
  # Argumentos::
  #   +user+ (User ou +nil+):: estudante da identificação lida.
  #   +restaurante+ (Restaurante ou +nil+):: restaurante do ponto de acesso.
  #   +tarifa+ (Integer):: tarifa vigente, em centavos.
  # Retorno:: par <tt>[status, inscricao]</tt>. O status é +:nao_encontrado+,
  #           +:sem_fastpass+ (não sorteado neste restaurante), +:fastpass_utilizado+,
  #           +:fora_do_time_frame+, +:saldo_insuficiente+ ou +:liberado+; a
  #           inscrição é +nil+ quando não há estudante ou inscrição contemplada.
  # Efeitos colaterais:: nenhum.
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

  # Indica se a leitura abriu a catraca, esteja a passagem pendente ou já confirmada.
  #
  # Argumentos:: nenhum.
  # Retorno:: +true+ quando o status é +liberado+ ou +confirmado+; +false+ nos bloqueios.
  # Efeitos colaterais:: nenhum.
  def liberou_catraca?
    liberado? || confirmado?
  end

  # Confirma que o estudante passou pela catraca e debita a refeição do saldo.
  #
  # Argumentos:: nenhum.
  # Retorno:: +true+ quando a passagem é confirmada; +false+ quando o acesso não
  #           está liberado (bloqueado ou já confirmado), o FastPass deixou de
  #           valer ou o saldo ficou insuficiente desde a leitura.
  # Efeitos colaterais:: com lock no acesso, na inscrição do FastPass e no
  #                      estudante, debita +valor_centavos+ do saldo, marca o
  #                      FastPass como utilizado e o acesso como +confirmado+.
  #                      Nas recusas, grava no acesso o status do motivo
  #                      (+sem_fastpass+, +fastpass_utilizado+ ou +saldo_insuficiente+)
  #                      e não altera o saldo.
  def confirmar_passagem!
    with_lock do
      liberado? && fastpass_valido_na_passagem? && debitar_passagem!
    end
  end

  private
    # Confere, no momento da passagem, se a inscrição do FastPass ainda está
    # sorteada.
    #
    # Argumentos:: nenhum.
    # Retorno:: +true+ na entrada comum ou com a inscrição ainda sorteada; +false+
    #           quando ela já foi utilizada ou deixou de estar sorteada.
    # Efeitos colaterais:: trava a inscrição (+lock!+); na recusa, grava no
    #                      acesso o status +fastpass_utilizado+ ou +sem_fastpass+.
    def fastpass_valido_na_passagem?
      return true if inscricao_fastpass.nil?

      inscricao_fastpass.lock!
      return true if inscricao_fastpass.sorteado?

      inscricao_fastpass.utilizado? ? fastpass_utilizado! : sem_fastpass!
      false
    end

    # Debita a passagem com o estudante travado, ou recusa por falta de saldo.
    #
    # Argumentos:: nenhum.
    # Retorno:: +true+ quando a passagem é efetivada; +false+ quando falta saldo.
    # Efeitos colaterais:: trava o estudante (+with_lock+) e delega a
    #                      #efetivar_passagem! ou #recusar_por_saldo!.
    def debitar_passagem!
      user.with_lock { saldo_cobre_passagem? ? efetivar_passagem! : recusar_por_saldo! }
    end

    # Indica se o saldo atual do estudante paga o valor da leitura.
    #
    # Argumentos:: nenhum.
    # Retorno:: +true+ quando o saldo é maior ou igual a +valor_centavos+; +false+ caso contrário.
    # Efeitos colaterais:: nenhum.
    def saldo_cobre_passagem?
      user.saldo_centavos >= valor_centavos
    end

    # Efetiva a passagem.
    #
    # Argumentos:: nenhum.
    # Retorno:: +true+.
    # Efeitos colaterais:: debita +valor_centavos+ do saldo do estudante, marca a
    #                      inscrição do FastPass (se houver) como utilizada e o
    #                      acesso como +confirmado+.
    def efetivar_passagem!
      user.update!(saldo_centavos: user.saldo_centavos - valor_centavos)
      inscricao_fastpass&.utilizado!
      confirmado!
    end

    # Recusa a passagem porque o saldo caiu desde a leitura.
    #
    # Argumentos:: nenhum.
    # Retorno:: +false+.
    # Efeitos colaterais:: grava no acesso o status +saldo_insuficiente+.
    def recusar_por_saldo!
      saldo_insuficiente!
      false
    end

    # Callback +before_validation+: quando só a catraca foi informada, assume o
    # restaurante dela.
    #
    # Argumentos:: nenhum.
    # Retorno:: o restaurante do acesso (ou +nil+); o valor não é usado.
    # Efeitos colaterais:: altera +restaurante+ em memória, antes de salvar.
    def sincronizar_restaurante_da_catraca
      self.restaurante ||= catraca&.restaurante
    end

    # Validação: a catraca precisa pertencer ao restaurante do acesso.
    #
    # Argumentos:: nenhum.
    # Retorno:: sem valor relevante.
    # Efeitos colaterais:: adiciona o erro +restaurante_divergente+ em +catraca+
    #                      quando a catraca é de outro restaurante.
    def catraca_do_restaurante
      return if catraca.nil? || restaurante_id.nil?

      errors.add(:catraca, :restaurante_divergente) if catraca.restaurante_id != restaurante_id
    end
end
