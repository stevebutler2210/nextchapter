require "test_helper"

class ClubTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @club = clubs(:one)
  end

  test "is valid with valid attributes" do
    assert @club.valid?
  end

  test "is invalid without a name" do
    @club.name = nil
    assert_not @club.valid?
  end

  test "is invalid with a duplicate name" do
    duplicate = Club.new(name: @club.name, created_by: @user)
    assert_not duplicate.valid?
  end

  test "has many memberships" do
    assert_respond_to @club, :memberships
  end

  test "has many members through memberships" do
    assert_respond_to @club, :members
  end
end
