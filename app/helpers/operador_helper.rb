module OperadorHelper
  STATUS_ACESSO = {
    "liberado" => [ "Liberado · aguardando passagem", "status--alerta" ],
    "confirmado" => [ "Passagem confirmada", "status--sucesso" ],
    "saldo_insuficiente" => [ "Bloqueado · saldo insuficiente", "status--erro" ],
    "nao_encontrado" => [ "Bloqueado · não encontrado", "status--erro" ]
  }.freeze

  def status_acesso(acesso)
    texto, modificador = STATUS_ACESSO.fetch(acesso.status)
    tag.span(texto, class: "status #{modificador}")
  end
end
