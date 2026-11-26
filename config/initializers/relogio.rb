# Soma o deslocamento do Relogio a Time.now quando o ajuste do horário do sistema
# está ligado (config.x.relogio.ajustavel, só no ambiente de desenvolvimento).
# Assim Time.current, Date.current e os created_at seguem o horário simulado.
if Rails.configuration.x.relogio.ajustavel
  module RelogioAjustavel
    def now(...)
      super + Relogio.deslocamento
    end
  end

  Time.singleton_class.prepend(RelogioAjustavel)
end
