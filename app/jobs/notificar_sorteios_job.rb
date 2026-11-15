# Disparado a cada minuto (config/recurring.yml): realiza os sorteios que
# chegaram ao T-60 e notifica os estudantes do resultado.
class NotificarSorteiosJob < ApplicationJob
  queue_as :default

  def perform
    Sorteio.notificar_pendentes!
  end
end
