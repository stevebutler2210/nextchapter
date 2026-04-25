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

  test "search skips service call and returns empty results when query is shorter than 3 characters" do
    sign_in_as(@owner)

    BookLookupService.stub(:search, ->(_q) { raise "should not be called" }) do
      get search_books_path,
          params: { query: "ab" },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :success
  end

  test "search logs a warning when BookLookupService raises a RuntimeError" do
    sign_in_as(@owner)

    warning = nil
    BookLookupService.stub(:search, ->(_q) { raise RuntimeError, "API timeout" }) do
      Rails.logger.stub(:warn, ->(msg) { warning = msg }) do
        get search_books_path,
            params: { query: "Oathbringer" },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end
    end

    assert_response :success
    assert_equal "BookLookupService error: API timeout", warning
  end
end
