# Horários do dia guardados como minutos desde a meia-noite (colunas *_min) e
# expostos como "HH:MM", sem depender de fuso horário.
module HorarioEmMinutos
  extend ActiveSupport::Concern

  FORMATO = /\A(\d{1,2}):(\d{2})(?::\d{2})?\z/

  class_methods do
    def horario(*atributos)
      atributos.each do |atributo|
        coluna = "#{atributo}_min"

        define_method(atributo) { HorarioEmMinutos.formatar(self[coluna]) }
        define_method("#{atributo}=") { |valor| self[coluna] = HorarioEmMinutos.em_minutos(valor) }
      end
    end
  end

  def self.formatar(minutos)
    format("%02d:%02d", *minutos.divmod(60)) if minutos
  end

  def self.em_minutos(valor)
    horas, minutos = valor.to_s.strip.match(FORMATO)&.captures&.map(&:to_i)
    horas * 60 + minutos if horas && horas < 24 && minutos < 60
  end

  def horario
    "#{hora_inicio} às #{hora_fim}"
  end
end
