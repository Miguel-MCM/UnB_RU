module OperadorHelper
  STATUS_ACESSO = {
    "liberado" => [ "Liberado · aguardando passagem", "status--alerta" ],
    "confirmado" => [ "Passagem confirmada", "status--sucesso" ],
    "saldo_insuficiente" => [ "Bloqueado · saldo insuficiente", "status--erro" ],
    "nao_encontrado" => [ "Bloqueado · não encontrado", "status--erro" ],
    "fora_do_time_frame" => [ "Bloqueado · fora do time-frame", "status--erro" ],
    "sem_fastpass" => [ "Bloqueado · sem FastPass", "status--erro" ],
    "fastpass_utilizado" => [ "Bloqueado · FastPass utilizado", "status--erro" ]
  }.freeze

  def status_acesso(acesso)
    texto, modificador = STATUS_ACESSO.fetch(acesso.status)
    tag.span(texto, class: "status #{modificador}")
  end

  # Motivo do bloqueio de uma leitura negada, exibido no terminal.
  def motivo_bloqueio(acesso)
    t("operador.acesso.motivos.#{acesso.status}")
  end
end
