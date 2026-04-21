require "test_helper"

class VotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:three)
    @nomination = nominations(:voting_one)
    @cycle = cycles(:voting)
    @club = clubs(:three)
  end

  test "member can cast a vote" do
    sign_in_as(@user)

    assert_difference "Vote.count", 1 do
      post nomination_votes_path(@nomination)
    end

    assert_redirected_to @club
    assert_equal @user, Vote.last.user
    assert_equal @nomination, Vote.last.nomination
  end

  test "duplicate vote for same cycle is rejected" do
    sign_in_as(users(:one))

    # users(:one) already has a vote on voting_one via fixtures
    post nomination_votes_path(nominations(:voting_two))

    assert_redirected_to @club
    assert_equal "User has already voted in this cycle", flash[:alert]
  end

  test "vote rejected when cycle is not in voting state" do
    sign_in_as(@user)

    post nomination_votes_path(nominations(:oathbringer))

    assert_redirected_to nominations(:oathbringer).cycle.club
    assert_equal "Voting is not open for this cycle", flash[:alert]
  end
end
