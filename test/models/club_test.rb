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

  test "has many cycles" do
    assert_respond_to @club, :cycles
  end

  test "current_cycle returns the active cycle" do
    active_cycle = cycles(:nominating)
    assert_equal active_cycle, @club.current_cycle
  end

  test "current_cycle returns nil when no active cycles exist" do
    @club.cycles.update_all(state: :complete)
    assert_nil @club.current_cycle
  end

  test "owned_by? returns true for owner" do
    assert @club.owned_by?(users(:one))
  end

  test "owned_by? returns false for non-owner member" do
    assert_not @club.owned_by?(users(:two))
  end
end
