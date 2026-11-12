class AccessLog < ApplicationRecord
  belongs_to :user
  belongs_to :restaurant
  belongs_to :turnstile

  validates :meal_type, :accessed_at, presence: true
  validates :amount_paid, numericality: { greater_than_or_equal_to: 0 }
  validate :turnstile_belongs_to_restaurant

  private

  def turnstile_belongs_to_restaurant
    return if turnstile.blank? || restaurant.blank?

    if turnstile.restaurant_id != restaurant_id
      errors.add(:turnstile, "não pertence ao restaurante informado")
    end
  end
end