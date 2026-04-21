require "test_helper"

class VoteTest < ActiveSupport::TestCase
  setup do
    @user = users(:three)
    @nomination = nominations(:voting_one)
    @cycle = cycles(:voting)
  end

  test "valid vote is saved and cycle_id is auto-populated" do
    vote = Vote.new(user: @user, nomination: @nomination)

    assert vote.save
    assert_equal @cycle.id, vote.cycle_id
  end

  test "duplicate vote for same user and cycle is rejected" do
    Vote.create!(user: users(:three), nomination: @nomination, cycle: @cycle)

    duplicate = Vote.new(user: users(:three), nomination: @nomination)

    err = assert_raises(ActiveRecord::RecordInvalid) { duplicate.save! }
    assert_includes err.message, "User has already voted in this cycle"
  end

  test "vote is rejected when cycle is not in voting state" do
    vote = Vote.new(user: @user, nomination: nominations(:oathbringer))

    assert_not vote.valid?
    assert_includes vote.errors[:base], "Voting is not open for this cycle"
  end

  test "cycle_id is set from nomination and not accepted from params" do
    vote = Vote.new(user: @user, nomination: @nomination, cycle_id: 99999)

    assert vote.save
    assert_equal @cycle.id, vote.cycle_id
    assert_not_equal 99999, vote.cycle_id
  end
end
