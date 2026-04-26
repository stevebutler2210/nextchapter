class User < ApplicationRecord
  has_secure_password

  encrypts :email_address, deterministic: true

  validates :name, presence: true
  validates :password, length: { minimum: 12 }, if: -> { password.present? }
  validates :email_address, uniqueness: { case_sensitive: false }

  has_many :sessions, dependent: :destroy
  has_many :nominations, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :reading_log_entries, dependent: :destroy

  has_many :refresh_tokens, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
