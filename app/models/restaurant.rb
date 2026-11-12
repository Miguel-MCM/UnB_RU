class Restaurant < ApplicationRecord
  has_many :turnstiles, dependent: :destroy
  has_many :access_logs, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end