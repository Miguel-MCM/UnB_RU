# Sorteio do FastPass de um turno em um dia de refeição. Nasce aberto para
# inscrições e é realizado 1 hora antes do início do turno, quando os inscritos
# com resultado são notificados.
class Sorteio < ApplicationRecord
  ANTECEDENCIA_MIN = 60

  belongs_to :turno
  has_many :inscricoes, class_name: "InscricaoFastpass", dependent: :destroy

  enum :status, {
    aberto: "aberto",
    encerrado: "encerrado",
    realizado: "realizado"
  }

  validates :data_refeicao, presence: true, uniqueness: { scope: :turno_id }

  # Sorteio do turno no dia (cria aberto se ainda não existir). Em uma corrida,
  # quem perde esbarra na validação de unicidade ou no índice único e passa a
  # buscar o sorteio criado pelo outro; se ele não existir, o erro sobe.
  def self.do_dia!(turno, data = Date.current)
    find_or_create_by!(turno:, data_refeicao: data)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    find_by!(turno:, data_refeicao: data)
  end

  # Realiza os sorteios e notifica os estudantes de todo turno que começa em
  # até 1 hora a partir de `agora`, no dia de `agora`. Idempotente: pode rodar a
  # cada minuto (NotificarSorteiosJob). Cada turno é isolado: um erro é
  # reportado e não impede os demais. Turnos que começam antes de 01:00 têm o
  # T-60 no dia anterior e são notificados com atraso, a partir de 00:00 do
  # próprio dia.
  def self.notificar_pendentes!(agora = Time.current)
    Turno.com_sorteio_ate(HorarioEmMinutos.minutos_do(agora)).find_each do |turno|
      do_dia!(turno, agora.to_date).notificar!(agora)
    rescue StandardError => e
      Rails.error.report(e, context: { turno_id: turno.id, data_refeicao: agora.to_date })
    end
  end

  # Realiza o sorteio (status "realizado", o que encerra as inscrições) e
  # notifica as inscrições com resultado ainda não notificadas. Não sorteia
  # inscrições ainda "inscrito" (o algoritmo com peso "Pity" está fora do
  # escopo); elas permanecem como estão e não são notificadas.
  def notificar!(agora = Time.current)
    with_lock do
      realizado! unless realizado?
      inscricoes.com_resultado.sem_notificacao.includes(:user, :time_frame, sorteio: :turno)
                .each { |inscricao| inscricao.notificar!(agora) }
    end
  end

  def encerrar!
    encerrado!
  end

  def inscricoes_abertas?
    aberto?
  end
end
