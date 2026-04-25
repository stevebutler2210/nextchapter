class RefreshToken < ApplicationRecord
  belongs_to :user

  has_secure_token :token

  scope :active, -> { where(revoked: false).where("expires_at > ?", Time.current) }

  def revoke!
    update!(revoked: true)
  end

  def expired?
    expires_at <= Time.current
  end

  def active?
    !revoked && !expired?
  end
end
