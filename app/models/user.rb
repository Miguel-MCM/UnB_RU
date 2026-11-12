class User < ApplicationRecord
  has_many :access_logs, dependent: :destroy
  has_many :recharges, dependent: :destroy

  validates :name, :registration_number, :role, presence: true
  validates :registration_number, uniqueness: true
  validates :role, inclusion: { in: %w[student admin] }

  def admin?
    role == "admin"
  end
end