require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:one)
  end

  test "search returns turbo stream when query is present" do
    sign_in_as(@owner)

    get search_books_path,
        params: { query: "Oathbringer" },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.content_type.split(";").first
  end
end
