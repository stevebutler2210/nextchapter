require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  setup do
    @membership = memberships(:owner)
  end

  test "is valid with valid attributes" do
    assert @membership.valid?
  end

  test "is invalid without a role" do
    @membership.role = nil
    assert_not @membership.valid?
  end

  test "is invalid with a duplicate user and club combination" do
    duplicate = Membership.new(
      user: @membership.user,
      club: @membership.club,
      role: "member"
    )
    assert_not duplicate.valid?
  end

  test "owner role is valid" do
    @membership.role = "owner"
    assert @membership.valid?
  end

  test "member role is valid" do
    @membership.role = "member"
    assert @membership.valid?
  end
end
