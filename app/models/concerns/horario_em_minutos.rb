# Concern para armazenar horários do dia como minutos desde a meia-noite
# (colunas +*_min+) e expô-los no formato +"HH:MM"+, sem depender de fuso
# horário.
module HorarioEmMinutos
  extend ActiveSupport::Concern

  # Expressão regular aceita para horários no formato "HH:MM" (com segundos opcionais).
  FORMATO = /\A(\d{1,2}):(\d{2})(?::\d{2})?\z/

  class_methods do
    # Declara leitores e escritores no formato +"HH:MM"+ para cada atributo de
    # horário mapeado à coluna +<atributo>_min+.
    #
    # Argumentos:: +atributos+ (Symbol/String...) nomes base dos horários.
    # Retorno:: +Array+ com os atributos recebidos.
    # Efeitos colaterais:: define dinamicamente na classe os métodos de leitura
    #                      e escrita para cada atributo informado.
    def horario(*atributos)
      atributos.each { |atributo| definir_acessores_horario(atributo) }
    end

    private
      # Define o par leitor/escritor de horário para um único atributo.
      #
      # Argumentos:: +atributo+ (Symbol/String) nome base do horário.
      # Retorno:: +Symbol+ com o nome do método escritor definido.
      # Efeitos colaterais:: define métodos de instância na classe.
      def definir_acessores_horario(atributo)
        definir_leitor_horario(atributo)
        definir_escritor_horario(atributo)
      end

      # Define o método leitor que formata a coluna +<atributo>_min+ em "HH:MM".
      #
      # Argumentos:: +atributo+ (Symbol/String) nome base do horário.
      # Retorno:: +Symbol+ com o nome do método leitor definido.
      # Efeitos colaterais:: define o método de instância +<atributo>+ na classe.
      def definir_leitor_horario(atributo)
        coluna = "#{atributo}_min"
        define_method(atributo) { HorarioEmMinutos.formatar(self[coluna]) }
      end

      # Define o método escritor que converte "HH:MM" para minutos na coluna
      # +<atributo>_min+.
      #
      # Argumentos:: +atributo+ (Symbol/String) nome base do horário.
      # Retorno:: +Symbol+ com o nome do método escritor definido.
      # Efeitos colaterais:: define o método de instância +<atributo>=+ na classe.
      def definir_escritor_horario(atributo)
        coluna = "#{atributo}_min"
        define_method("#{atributo}=") { |valor| self[coluna] = HorarioEmMinutos.em_minutos(valor) }
      end
  end

  # Formata uma quantidade de minutos desde a meia-noite como +"HH:MM"+.
  #
  # Argumentos:: +minutos+ (Integer ou nil) contados desde 00:00.
  # Retorno:: +String+ no formato +"HH:MM"+ quando +minutos+ é informado; +nil+
  #           quando +minutos+ é +nil+.
  # Efeitos colaterais:: nenhum.
  def self.formatar(minutos)
    format("%02d:%02d", *minutos.divmod(60)) if minutos
  end

  # Converte uma representação textual de horário ("HH:MM" ou "HH:MM:SS") em
  # minutos desde a meia-noite.
  #
  # Argumentos:: +valor+ (String/Object) contendo o horário a converter.
  # Retorno:: +Integer+ entre 0 e 1439 quando o formato e os limites (hora < 24,
  #           minuto < 60) são válidos; +nil+ caso contrário.
  # Efeitos colaterais:: nenhum.
  def self.em_minutos(valor)
    horas, minutos = valor.to_s.strip.match(FORMATO)&.captures&.map(&:to_i)
    horas * 60 + minutos if horas && horas < 24 && minutos < 60
  end

  # Extrai o minuto do dia (desde a meia-noite) de um objeto de tempo.
  #
  # Argumentos:: +momento+ (Time/DateTime/ActiveSupport::TimeWithZone) que
  #              responde a +#hour+ e +#min+.
  # Retorno:: +Integer+ entre 0 e 1439 representando o minuto do dia.
  # Efeitos colaterais:: nenhum.
  def self.minutos_do(momento)
    momento.hour * 60 + momento.min
  end

  # Verifica se o intervalo definido por +hora_inicio_min+ e +hora_fim_min+
  # inclui o minuto informado (extremos inclusivos).
  #
  # Argumentos:: +minutos+ (Integer) contados desde a meia-noite.
  # Retorno:: +true+ quando +minutos+ está entre início e fim (inclusive);
  #           +false+ caso contrário.
  # Efeitos colaterais:: nenhum.
  def cobre?(minutos)
    minutos.between?(hora_inicio_min, hora_fim_min)
  end

  # Calcula a distância em minutos entre +minutos+ e o intervalo do registro.
  #
  # Argumentos:: +minutos+ (Integer) contados desde a meia-noite.
  # Retorno:: +Integer+ >= 0 (+0+ quando o intervalo cobre o minuto informado).
  # Efeitos colaterais:: nenhum.
  def distancia_de(minutos)
    [ hora_inicio_min - minutos, minutos - hora_fim_min, 0 ].max
  end

  # Formata o intervalo do registro para exibição ("HH:MM às HH:MM").
  #
  # Argumentos:: nenhum.
  # Retorno:: +String+ no formato +"<hora_inicio> às <hora_fim>"+.
  # Efeitos colaterais:: nenhum.
  def horario
    "#{hora_inicio} às #{hora_fim}"
  end
end
