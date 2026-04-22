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
  test "close_nominations! transitions from nominating to voting" do
    cycle = cycles(:nominating)
    assert_equal "nominating", cycle.state
    cycle.close_nominations!
    assert_equal "voting", cycle.reload.state
  end

  test "close_voting_and_select_winner! returns :clear_winner and sets the leading nomination" do
    cycle = cycles(:voting)
    # voting_one and voting_two each have 1 vote via fixtures — add a second vote to voting_one
    Vote.create!(user: users(:three), nomination: nominations(:voting_one), cycle: cycle)

    result = cycle.close_voting_and_select_winner!

    assert_equal :clear_winner, result
    assert_equal "reading", cycle.reload.state
    assert_equal nominations(:voting_one), cycle.winning_nomination
  end

  test "close_voting_and_select_winner! returns :tied and picks a winner randomly on a tie" do
    cycle = cycles(:voting)
    # voting_one and voting_two each have exactly 1 vote via fixtures — genuine tie

    result = cycle.close_voting_and_select_winner!

    assert_equal :tied, result
    assert_equal "reading", cycle.reload.state
    assert_includes [ nominations(:voting_one), nominations(:voting_two) ], cycle.winning_nomination
  end

  test "complete! transitions from reading to complete" do
    cycle = cycles(:voting)
    cycle.close_voting_and_select_winner!
    cycle.complete!
    assert_equal "complete", cycle.reload.state
  end

  # Invalid transitions
  test "close_nominations! raises when not in nominating state" do
    cycle = cycles(:nominating)
    cycle.update!(state: :voting)
    assert_raises(RuntimeError) { cycle.close_nominations! }
  end

  test "close_nominations! raises when there are no nominations" do
    club = Club.create!(name: "Empty Club", created_by: users(:one))
    cycle = club.cycles.create!(state: :nominating)
    assert_raises(RuntimeError) { cycle.close_nominations! }
  end

  test "close_voting_and_select_winner! raises when not in voting state" do
    cycle = cycles(:nominating)
    assert_raises(RuntimeError) { cycle.close_voting_and_select_winner! }
  end

  test "close_voting_and_select_winner! raises when no votes have been cast" do
    cycle = cycles(:voting)
    cycle.votes.delete_all
    assert_raises(RuntimeError) { cycle.close_voting_and_select_winner! }
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
