# Helpers das telas da Aplicação de Controle.
module OperadorHelper
  # Texto e classe CSS de cada status de Acesso na tabela de validações.
  STATUS_ACESSO = {
    "liberado" => [ "Liberado · aguardando passagem", "status--alerta" ],
    "confirmado" => [ "Passagem confirmada", "status--sucesso" ],
    "saldo_insuficiente" => [ "Bloqueado · saldo insuficiente", "status--erro" ],
    "nao_encontrado" => [ "Bloqueado · não encontrado", "status--erro" ],
    "fora_do_time_frame" => [ "Bloqueado · fora do time-frame", "status--erro" ],
    "sem_fastpass" => [ "Bloqueado · sem FastPass", "status--erro" ],
    "fastpass_utilizado" => [ "Bloqueado · FastPass utilizado", "status--erro" ]
  }.freeze

  # Selo do status de uma leitura, colorido conforme o resultado.
  #
  # Argumentos:: +acesso+ (Acesso).
  # Retorno:: <tt><span class="status status--..."></tt> com o texto do status
  #           (sucesso, alerta ou erro).
  # Efeitos colaterais:: nenhum. Levanta KeyError para um status sem entrada
  #                      em STATUS_ACESSO.
  def status_acesso(acesso)
    texto, modificador = STATUS_ACESSO.fetch(acesso.status)
    tag.span(texto, class: "status #{modificador}")
  end

  # Motivo do bloqueio de uma leitura negada, exibido no terminal.
  #
  # Argumentos:: +acesso+ (Acesso) com status de bloqueio.
  # Retorno:: o texto de <tt>operador.acesso.motivos.<status></tt> no
  #           +pt-BR.yml+ (ex.: "Saldo insuficiente").
  # Efeitos colaterais:: nenhum.
  def motivo_bloqueio(acesso)
    t("operador.acesso.motivos.#{acesso.status}")
  end
end
