# Representa o cardápio de uma refeição servida em uma data específica do RU.
class Menu < ApplicationRecord
  # Tipos de refeição suportados pelo sistema.
  MEAL_TYPES = %w[cafe_da_manha almoco jantar].freeze

  # Faixas de horário (em minutos a partir da meia-noite) de cada refeição.
  MEAL_WINDOWS = {
    "cafe_da_manha" => (7 * 60)..((9 * 60) + 30),
    "almoco" => (11 * 60)..((14 * 60) + 30),
    "jantar" => (17 * 60)..((19 * 60) + 30)
  }.freeze

  # Rótulos legíveis em português para exibição dos tipos de refeição.
  MEAL_LABELS = {
    "cafe_da_manha" => "café da manhã",
    "almoco" => "almoço",
    "jantar" => "jantar"
  }.freeze

  validates :served_on, :meal_type, :standard_dish, :ovolacto_dish, :vegan_dish, presence: true
  validates :meal_type, inclusion: { in: MEAL_TYPES }

  # Determina qual tipo de refeição está sendo servido no instante informado.
  #
  # Argumentos::
  #   +time+:: (+Time+, padrão +Time.current+) instante de referência para verificar a faixa horária.
  # Retorno:: +String+ com o identificador do turno (+cafe_da_manha+, +almoco+ ou +jantar+)
  #           ou +nil+ quando o horário está fora do funcionamento das refeições.
  # Efeitos colaterais:: nenhum.
  def self.current_meal_type(time = Time.current)
    minutes = (time.hour * 60) + time.min
    MEAL_WINDOWS.find { |_type, range| range.cover?(minutes) }&.first
  end

  # Traduz o identificador interno do tipo de refeição para o rótulo em português.
  #
  # Argumentos::
  #   +meal_type+:: (+String+) identificador do turno (+cafe_da_manha+, +almoco+ ou +jantar+).
  # Retorno:: +String+ com o nome legível do turno ou +nil+ se o tipo for desconhecido.
  # Efeitos colaterais:: nenhum.
  def self.meal_label(meal_type)
    MEAL_LABELS[meal_type]
  end
end
