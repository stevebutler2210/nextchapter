# test/models/refresh_token_test.rb

require "test_helper"

class RefreshTokenTest < ActiveSupport::TestCase
  test "active? returns true for a valid non-revoked unexpired token" do
    token = refresh_tokens(:active)
    assert token.active?
  end

  test "active? returns false when revoked" do
    token = refresh_tokens(:active)
    token.revoke!
    assert_not token.active?
  end

  test "active? returns false when expired" do
    token = RefreshToken.new(expires_at: 1.day.ago, revoked: false)
    assert_not token.active?
  end

  test "expired? returns true when expires_at is in the past" do
    token = RefreshToken.new(expires_at: 1.hour.ago)
    assert token.expired?
  end

  test "expired? returns false when expires_at is in the future" do
    token = RefreshToken.new(expires_at: 1.hour.from_now)
    assert_not token.expired?
  end

  test "revoke! sets revoked to true" do
    token = refresh_tokens(:active)
    assert_not token.revoked
    token.revoke!
    assert token.reload.revoked
  end

  test "active scope excludes revoked tokens" do
    token = refresh_tokens(:active)
    token.revoke!
    assert_not RefreshToken.active.include?(token)
  end

  test "active scope excludes expired tokens" do
    token = refresh_tokens(:active)
    token.update!(expires_at: 1.day.ago)
    assert_not RefreshToken.active.include?(token)
  end

  test "active scope includes valid tokens" do
    assert RefreshToken.active.include?(refresh_tokens(:active))
  end
end
