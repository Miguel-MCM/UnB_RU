# Sorteio do FastPass de um turno em um dia de refeição. Nasce aberto para
# inscrições e é realizado 1 hora antes do início do turno, quando os inscritos
# com resultado são notificados.
class Sorteio < ApplicationRecord
  # Antecedência em minutos em relação ao início do turno para realização do sorteio.
  ANTECEDENCIA_MIN = 60

  belongs_to :turno
  has_many :inscricoes, class_name: "InscricaoFastpass", dependent: :destroy

  enum :status, {
    aberto: "aberto",
    encerrado: "encerrado",
    realizado: "realizado"
  }

  validates :data_refeicao, presence: true, uniqueness: { scope: :turno_id }

  # Obtém ou cria o sorteio aberto do turno na data informada. Em caso de
  # corrida entre requisições, recupera o registro criado pela transação
  # concorrente; se ainda assim não existir, propaga o erro.
  #
  # Argumentos:: +turno+ (Turno) e +data+ (Date, opcional; padrão
  #              +Date.current+).
  # Retorno:: +Sorteio+ persistido correspondente ao turno e à data; lança
  #           +ActiveRecord::RecordNotFound+ se falhar fora de cenário de corrida.
  # Efeitos colaterais:: cria um registro de +Sorteio+ no banco quando ainda não
  #                      existe para o par +(turno, data)+.
  def self.do_dia!(turno, data = Date.current)
    find_or_create_by!(turno:, data_refeicao: data)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    find_by!(turno:, data_refeicao: data)
  end

  # Realiza os sorteios e notifica os estudantes de todos os turnos que começam
  # em até 1 hora a partir de +agora+, no dia de +agora+. É idempotente e isola
  # falhas por turno, reportando exceções via +Rails.error+. Turnos antes de
  # 01:00 têm T-60 no dia anterior e são notificados a partir de 00:00 do dia.
  #
  # Argumentos:: +agora+ (Time/ActiveSupport::TimeWithZone, opcional; padrão
  #              +Time.current+).
  # Retorno:: +nil+ (retorno de +find_each+).
  # Efeitos colaterais:: cria ou atualiza registros de +Sorteio+ para
  #                      +realizado+, cria registros de +Notificacao+ no banco e
  #                      reporta erros individuais em +Rails.error+.
  def self.notificar_pendentes!(agora = Time.current)
    Turno.com_sorteio_ate(HorarioEmMinutos.minutos_do(agora)).find_each do |turno|
      do_dia!(turno, agora.to_date).notificar!(agora)
    rescue StandardError => e
      Rails.error.report(e, context: { turno_id: turno.id, data_refeicao: agora.to_date })
    end
  end

  # Marca o sorteio como realizado (encerrando inscrições) e notifica todas as
  # inscrições com resultado ainda não notificadas. Inscrições ainda no status
  # +inscrito+ permanecem intactas e não são notificadas.
  #
  # Argumentos:: +agora+ (Time/ActiveSupport::TimeWithZone, opcional; padrão
  #              +Time.current+) usado como horário de envio das notificações.
  # Retorno:: relação de +InscricaoFastpass+ percorrida durante a notificação.
  # Efeitos colaterais:: adquire lock no registro do +Sorteio+, atualiza seu
  #                      status para +realizado+ se necessário e cria registros
  #                      de +Notificacao+ no banco para as inscrições pendentes.
  def notificar!(agora = Time.current)
    with_lock do
      realizado! unless realizado?
      inscricoes.com_resultado.sem_notificacao.includes(:user, :time_frame, sorteio: :turno)
                .each { |inscricao| inscricao.notificar!(agora) }
    end
  end

  # Encerra manualmente as inscrições deste sorteio.
  #
  # Argumentos:: nenhum.
  # Retorno:: +true+ ao persistir o novo status (ou lança exceção em caso de
  #           falha na persistência).
  # Efeitos colaterais:: atualiza a coluna +status+ do +Sorteio+ para
  #                      +encerrado+ no banco de dados.
  def encerrar!
    encerrado!
  end

  # Indica se o sorteio ainda aceita novas inscrições no FastPass.
  #
  # Argumentos:: nenhum.
  # Retorno:: +true+ quando o status é +aberto+; +false+ quando é +encerrado+ ou
  #           +realizado+.
  # Efeitos colaterais:: nenhum.
  def inscricoes_abertas?
    aberto?
  end
end
