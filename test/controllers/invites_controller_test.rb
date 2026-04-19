require "test_helper"

class InvitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_one = users(:one)
    @user_two = users(:two)
    # club :two is owned by user :two; user :one has no membership in it
    @club = clubs(:two)
    @valid_token = @club.signed_id(expires_in: 1.week)
  end

  test "valid invite: member is added and redirected with notice" do
    sign_in_as(@user_one)

    assert_difference "@club.memberships.count", 1 do
      get invite_path(signed_id: @valid_token)
    end

    assert_redirected_to club_path(@club)
    follow_redirect!
    assert_equal "You've joined #{@club.name}.", flash[:notice]
  end

  test "already a member: redirected with alert and no duplicate membership" do
    # user :two is a member of club :one via fixtures
    club_one = clubs(:one)
    token = club_one.signed_id(expires_in: 1.week)
    sign_in_as(@user_two)

    assert_no_difference "club_one.memberships.count" do
      get invite_path(signed_id: token)
    end

    assert_redirected_to club_path(club_one)
    follow_redirect!
    assert_equal "You're already a member of this club.", flash[:alert]
  end

  test "invalid token: renders invalid template with 404" do
    sign_in_as(@user_one)
    get invite_path(signed_id: "this-is-garbage")

    assert_response :not_found
    assert_select "h1", "Invite Link Invalid"
  end

  test "unauthenticated user: redirected to sign in with alert and return_to set" do
    get invite_path(signed_id: @valid_token)

    assert_redirected_to new_session_path
    follow_redirect!
    assert_equal "Please sign in to accept the invite.", flash[:alert]
    assert_equal invite_url(signed_id: @valid_token), session[:return_to_after_authenticating]
  end
end
