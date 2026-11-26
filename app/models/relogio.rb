# Relógio do sistema, ajustável pelo administrador para demonstrações e testes
# manuais (ex.: avançar para dentro de um turno e ver o FastPass funcionar).
#
# Guarda só o deslocamento, em segundos, entre o relógio real e o do sistema; o
# relógio simulado continua andando a partir do horário ajustado. O registro é
# único (ver Relogio.atual). O ajuste só vale quando
# <tt>config.x.relogio.ajustavel</tt> está ligado (ambiente de desenvolvimento):
# nesse caso o initializer +relogio.rb+ soma Relogio.deslocamento a +Time.now+,
# e por isso +Time.current+, +Date.current+ e os +created_at+ seguem o horário
# simulado. Fora disso o deslocamento nunca é aplicado.
class Relogio < ApplicationRecord
  # Intervalo, em segundos, entre leituras do deslocamento no banco.
  VALIDADE_DO_CACHE = 1

  # Deslocamento, em minutos, de cada sentido de DESLOCAR (setas + e −).
  PASSO_EM_MINUTOS = 30
  SENTIDOS = { "mais" => PASSO_EM_MINUTOS, "menos" => -PASSO_EM_MINUTOS }.freeze

  attr_reader :horario_simulado

  validates :deslocamento_segundos, numericality: { only_integer: true }
  validate :horario_simulado_valido

  class << self
    # Indica se o horário do sistema pode ser ajustado neste ambiente.
    #
    # Argumentos:: nenhum.
    # Retorno:: +true+ quando <tt>config.x.relogio.ajustavel</tt> está ligado.
    # Efeitos colaterais:: nenhum.
    def ajustavel?
      Rails.configuration.x.relogio.ajustavel.present?
    end

    # Horário real da máquina, ignorando qualquer ajuste.
    #
    # Argumentos:: nenhum.
    # Retorno:: Time do relógio real.
    # Efeitos colaterais:: nenhum.
    def agora_real
      Time.at(Process.clock_gettime(Process::CLOCK_REALTIME))
    end

    # Registro único do relógio (criado zerado na primeira chamada).
    #
    # Argumentos:: nenhum.
    # Retorno:: o Relogio.
    # Efeitos colaterais:: pode criar o registro.
    def atual
      first || create!
    end

    # Deslocamento atual em segundos, lido do banco no máximo uma vez por
    # VALIDADE_DO_CACHE segundo (é chamado a cada +Time.now+). Sem tabela ou
    # banco (ex.: durante o setup), vale 0.
    #
    # Argumentos:: nenhum.
    # Retorno:: Integer (positivo avança, negativo atrasa o relógio).
    # Efeitos colaterais:: atualiza o cache em memória do processo.
    def deslocamento
      return @deslocamento.to_i if @carregando

      recarregar_deslocamento if cache_vencido?
      @deslocamento.to_i
    end

    # Indica se o sistema está com o horário simulado.
    #
    # Argumentos:: nenhum.
    # Retorno:: +true+ quando há ajuste ligado e o deslocamento não é zero.
    # Efeitos colaterais:: nenhum.
    def ajustado?
      ajustavel? && deslocamento != 0
    end

    # Descarta o cache para que a próxima leitura vá ao banco.
    #
    # Argumentos:: nenhum.
    # Retorno:: +nil+.
    # Efeitos colaterais:: zera o cache em memória.
    def limpar_cache
      @verificado_em = nil
    end

    private
      def cache_vencido?
        @verificado_em.nil? || Process.clock_gettime(Process::CLOCK_MONOTONIC) - @verificado_em > VALIDADE_DO_CACHE
      end

      def recarregar_deslocamento
        @carregando = true
        @deslocamento = ActiveRecord::Base.with_connection { first&.deslocamento_segundos } || 0
      rescue ActiveRecord::ActiveRecordError
        @deslocamento = 0
      ensure
        @carregando = false
        @verificado_em = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
  end

  # Ajusta o relógio do sistema para o horário informado.
  #
  # Argumentos:: +texto+ (String): data e hora no fuso do sistema, como o campo
  #              +datetime-local+ envia (ex.: <tt>"2026-11-26T11:30"</tt>).
  # Retorno:: +true+ quando ajustou; +false+ quando o texto é vazio ou inválido
  #           (erro em +horario_simulado+).
  # Efeitos colaterais:: grava o deslocamento e limpa o cache do processo.
  def ajustar_para(texto)
    @horario_simulado = texto.to_s.strip
    momento = interpretar_horario
    self.deslocamento_segundos = (momento - self.class.agora_real).round if momento
    persistir_ajuste
  end

  # Avança ou atrasa o relógio do sistema em meia hora (PASSO_EM_MINUTOS).
  #
  # Argumentos:: +sentido+ (String): <tt>"mais"</tt> ou <tt>"menos"</tt>.
  # Retorno:: +true+.
  # Efeitos colaterais:: soma ou subtrai 30 minutos do deslocamento gravado e
  #                      limpa o cache do processo. Levanta KeyError para um
  #                      sentido desconhecido.
  def deslocar!(sentido)
    minutos = SENTIDOS.fetch(sentido.to_s)
    update!(deslocamento_segundos: deslocamento_segundos + minutos * 60)
    self.class.limpar_cache
    true
  end

  # Volta o relógio do sistema para o horário real.
  #
  # Argumentos:: nenhum.
  # Retorno:: +true+.
  # Efeitos colaterais:: zera o deslocamento e limpa o cache do processo.
  def restaurar!
    update!(deslocamento_segundos: 0)
    self.class.limpar_cache
    true
  end

  # Horário do sistema agora (real mais o deslocamento gravado).
  #
  # Argumentos:: nenhum.
  # Retorno:: Time no fuso do sistema.
  # Efeitos colaterais:: nenhum.
  def horario_do_sistema
    (self.class.agora_real + deslocamento_segundos).in_time_zone
  end

  private
    def persistir_ajuste
      return false unless valid?

      save!
      self.class.limpar_cache
      true
    end

    def interpretar_horario
      Time.zone.parse(@horario_simulado) if @horario_simulado.present?
    rescue ArgumentError
      nil
    end

    def horario_simulado_valido
      return if @horario_simulado.nil?

      errors.add(:horario_simulado, @horario_simulado.blank? ? :blank : :invalid) if interpretar_horario.nil?
    end
end
