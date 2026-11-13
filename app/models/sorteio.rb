# Sorteio do FastPass de um turno em um dia de refeição. Nasce aberto para
# inscrições e é encerrado antes de ser realizado.
class Sorteio < ApplicationRecord
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

  def encerrar!
    encerrado!
  end

  def inscricoes_abertas?
    aberto?
  end
end
