class Turnstile < ApplicationRecord
  belongs_to :restaurant
  has_many :access_logs, dependent: :destroy

  validates :name, presence: true
end