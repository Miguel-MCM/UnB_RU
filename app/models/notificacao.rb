# Aviso ao estudante do resultado do sorteio do FastPass, gerado uma única vez
# por inscrição quando o sorteio é realizado (1 hora antes do turno).
class Notificacao < ApplicationRecord
  belongs_to :user
  belongs_to :inscricao_fastpass

  enum :tipo, {
    contemplado: "contemplado",
    nao_contemplado: "nao_contemplado"
  }

  validates :tipo, :mensagem, :enviada_em, presence: true
  validates :inscricao_fastpass_id, uniqueness: true

  scope :recentes, -> { order(enviada_em: :desc, id: :desc) }
end
