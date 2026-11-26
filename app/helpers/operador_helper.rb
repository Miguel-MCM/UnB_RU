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

  # Links para trocar a catraca gerenciada, um por catraca do restaurante.
  #
  # Argumentos:: +restaurante+ (Restaurante), +atual+ (Catraca ou +nil+) e
  #              +rota+ (Symbol): helper de rota que recebe +catraca_id:+
  #              (ex.: <tt>:operador_terminal_path</tt>).
  # Retorno:: SafeBuffer com um link por catraca (a atual, em texto simples),
  #           separados por " · "; os nomes são escapados.
  # Efeitos colaterais:: nenhum.
  def links_de_catracas(restaurante, atual, rota)
    links = restaurante.catracas.map do |catraca|
      link_to_unless(catraca == atual, catraca.nome, public_send(rota, catraca_id: catraca.id))
    end
    safe_join(links, " · ")
  end

  # Indica se as setas de ajuste do horário aparecem ao lado do relógio.
  #
  # Argumentos:: nenhum (usa +current_funcionario+).
  # Retorno:: +true+ para administrador, com o ajuste de horário ligado.
  # Efeitos colaterais:: nenhum.
  def ajuste_de_horario_visivel?
    Relogio.ajustavel? && current_funcionario&.administrador?
  end
end
