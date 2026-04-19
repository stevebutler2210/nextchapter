require "test_helper"

class ClubsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:one)
    @non_owner = users(:two)
    @club = clubs(:one)
  end

  test "owner can edit their club" do
    sign_in_as(@owner)

    get edit_club_path(@club)
    assert_response :success

    patch club_path(@club), params: { club: { name: "Updated Club Name", description: "Updated description" } }
    assert_redirected_to club_path(@club)
    assert_equal "Updated Club Name", @club.reload.name
  end

  test "owner can delete their club" do
    sign_in_as(@owner)

    assert_difference("Club.count", -1) do
      delete club_path(@club)
    end

    assert_redirected_to clubs_path
  end

  test "non-owner gets 403 on edit" do
    sign_in_as(@non_owner)

    get edit_club_path(@club)
    assert_response :forbidden
  end

  test "non-owner gets 403 on update" do
    sign_in_as(@non_owner)

    patch club_path(@club), params: { club: { name: "Should Not Update" } }
    assert_response :forbidden
  end

  test "non-owner gets 403 on destroy" do
    sign_in_as(@non_owner)

    delete club_path(@club)
    assert_response :forbidden
  end

  test "unauthenticated user is redirected on edit" do
    get edit_club_path(@club)

    assert_redirected_to new_session_path
  end

  test "unauthenticated user is redirected on update" do
    patch club_path(@club), params: { club: { name: "Nope" } }

    assert_redirected_to new_session_path
  end

  test "unauthenticated user is redirected on destroy" do
    delete club_path(@club)

    assert_redirected_to new_session_path
  end
end
