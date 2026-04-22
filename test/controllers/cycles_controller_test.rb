require "test_helper"

class CyclesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:one)
    @non_owner = users(:two)
    @voting_cycle = cycles(:voting)
  end

  test "owner can close voting with a clear winner" do
    sign_in_as(@owner)

    Vote.create!(user: users(:three), nomination: nominations(:voting_one))

    patch close_voting_cycle_path(@voting_cycle)

    assert_redirected_to @voting_cycle.club
    assert_equal "Voting closed.", flash[:notice]

    @voting_cycle.reload
    assert_equal "reading", @voting_cycle.state
    assert_equal nominations(:voting_one), @voting_cycle.winning_nomination
  end

  test "owner can close voting with a tie" do
    sign_in_as(@owner)

    patch close_voting_cycle_path(@voting_cycle)

    assert_redirected_to @voting_cycle.club
    assert_equal "Voting closed. A tie was randomly broken to select the winner.", flash[:notice]

    @voting_cycle.reload
    assert_equal "reading", @voting_cycle.state
    assert_includes [ nominations(:voting_one), nominations(:voting_two) ], @voting_cycle.winning_nomination
  end

  test "non-owner gets 403 when trying to close voting" do
    sign_in_as(@non_owner)

    patch close_voting_cycle_path(@voting_cycle)

    assert_response :forbidden
    assert_equal "voting", @voting_cycle.reload.state
    assert_nil @voting_cycle.winning_nomination
  end

  test "close voting is rejected when cycle is not in voting state" do
    sign_in_as(@owner)
    non_voting_cycle = cycles(:nominating)

    patch close_voting_cycle_path(non_voting_cycle)

    assert_redirected_to non_voting_cycle.club
    assert_equal "Cannot close voting from nominating", flash[:alert]
    assert_equal "nominating", non_voting_cycle.reload.state
    assert_nil non_voting_cycle.winning_nomination
  end
end
