require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "name is required" do
    user = User.new(email_address: "test@example.com", password: "password123456")
    assert_not user.valid?
    assert_includes user.errors.full_messages, "Name can't be blank"
  end

  test "user can be created with valid name" do
    user = User.new(
      name: "John Doe",
      email_address: "john@example.com",
      password: "password123456",
      password_confirmation: "password123456"
    )
    assert user.valid?
  end
end
