class Menu < ApplicationRecord
  MEAL_TYPES = %w[cafe_da_manha almoco jantar].freeze

  validates :served_on, :meal_type, :standard_dish, :ovolacto_dish, :vegan_dish, presence: true
  validates :meal_type, inclusion: { in: MEAL_TYPES }

  def self.current_meal_type(time = Time.current)
    minutes = time.hour * 60 + time.min
    if minutes.between?(7 * 60, 9 * 60 + 30)
      "cafe_da_manha"
    elsif minutes.between?(11 * 60, 14 * 60 + 30)
      "almoco"
    elsif minutes.between?(17 * 60, 19 * 60 + 30)
      "jantar"
    end
  end

  def self.meal_label(meal_type)
    {
      "cafe_da_manha" => "café da manhã",
      "almoco" => "almoço",
      "jantar" => "jantar"
    }[meal_type]
  end
end