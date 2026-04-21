require "test_helper"

class CycleTest < ActiveSupport::TestCase
  setup do
    @club = clubs(:one)
  end

  # Valid creation tests
  test "is valid with valid attributes" do
    # Create a club without active cycles for this test
    club_without_cycle = Club.create!(name: "Test Club", created_by: users(:one))
    cycle = Cycle.new(club: club_without_cycle, state: "nominating")
    assert cycle.valid?
  end

  test "has default state of nominating" do
    club_without_cycle = Club.create!(name: "Test Club 2", created_by: users(:one))
    cycle = Cycle.new(club: club_without_cycle)
    assert_equal "nominating", cycle.state
  end

  test "is invalid without a club" do
    cycle = Cycle.new(state: "nominating")
    assert_not cycle.valid?
  end

  test "is invalid without a state" do
    cycle = Cycle.new(club: @club, state: nil)
    assert_not cycle.valid?
  end

  # State enum tests
  test "has all valid state enums" do
    assert_equal %w[nominating voting reading complete], Cycle.states.keys.map(&:to_s)
  end

  # Valid transitions
  test "advance_to_voting! transitions from nominating to voting" do
    cycle = cycles(:nominating)
    assert_equal "nominating", cycle.state
    cycle.advance_to_voting!
    assert_equal "voting", cycle.reload.state
  end

  test "advance_to_reading! transitions from voting to reading" do
    cycle = cycles(:nominating)
    cycle.update!(state: :voting)
    cycle.advance_to_reading!
    assert_equal "reading", cycle.reload.state
  end

  test "complete! transitions from reading to complete" do
    cycle = cycles(:nominating)
    cycle.update!(state: :reading)
    cycle.complete!
    assert_equal "complete", cycle.reload.state
  end

  # Invalid transitions
  test "advance_to_voting! raises when not in nominating state" do
    cycle = cycles(:nominating)
    cycle.update!(state: :voting)
    assert_raises(RuntimeError) { cycle.advance_to_voting! }
  end

  test "advance_to_reading! raises when not in voting state" do
    cycle = cycles(:nominating)
    assert_raises(RuntimeError) { cycle.advance_to_reading! }
  end

  test "complete! raises when not in reading state" do
    cycle = cycles(:nominating)
    assert_raises(RuntimeError) { cycle.complete! }
  end

  # One active cycle per club constraint
  test "is invalid when club already has an active cycle" do
    existing_cycle = cycles(:nominating)
    assert existing_cycle.valid?

    new_cycle = Cycle.new(club: @club, state: "nominating")
    assert_not new_cycle.valid?
    assert new_cycle.errors.full_messages.join(", ").include?("only have one active cycle")
  end

  test "allows a new active cycle after existing cycle is complete" do
    existing_cycle = cycles(:nominating)
    existing_cycle.update!(state: :complete)

    new_cycle = Cycle.new(club: @club, state: "nominating")
    assert new_cycle.valid?
  end

  test "allows multiple complete cycles for a club" do
    cycle1 = cycles(:nominating)
    cycle1.update!(state: :complete)

    cycle2 = @club.cycles.create!(state: "nominating")
    cycle2.update!(state: :complete)

    assert cycle1.complete?
    assert cycle2.complete?
  end

  # Belongs to club
  test "belongs to club" do
    cycle = cycles(:nominating)
    assert_equal @club, cycle.club
  end

  # Timestamps
  test "has timestamps" do
    cycle = cycles(:nominating)
    assert_not_nil cycle.created_at
    assert_not_nil cycle.updated_at
  end
end
