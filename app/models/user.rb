class User < ApplicationRecord
  has_secure_password
  validates :password, length: { minimum: 12 }, if: -> { password.present? }
  validates :email_address, uniqueness: { case_sensitive: false }

  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
