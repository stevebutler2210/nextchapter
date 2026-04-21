require "test_helper"

class NominationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @cycle = cycles(:nominating)
    @book = books(:oathbringer)
  end

  def book_params(book_fixture = @book)
    {
      google_books_id: book_fixture.google_books_id,
      title: book_fixture.title,
      authors: book_fixture.authors,
      isbn: book_fixture.isbn,
      description: book_fixture.description,
      cover_url: book_fixture.cover_url,
      publisher: book_fixture.publisher,
      published_date: book_fixture.published_date,
      page_count: book_fixture.page_count
    }
  end

  test "member can nominate a book" do
    sign_in_as(users(:three))

    assert_difference "Nomination.count", 1 do
      post cycle_nominations_path(@cycle), params: book_params(books(:the_hobbit))
    end

    assert_redirected_to @cycle.club
    assert_equal books(:the_hobbit), Nomination.last.book
    assert_equal users(:three), Nomination.last.user
  end

  test "duplicate nomination updates existing rather than creating a new one" do
    sign_in_as(@user)

    # users(:one) already has oathbringer nominated via fixtures —
    # this updates that nomination to the_hobbit
    assert_no_difference "Nomination.count" do
      post cycle_nominations_path(@cycle), params: book_params(books(:the_hobbit))
    end

    assert_redirected_to @cycle.club
    assert_equal books(:the_hobbit), @user.nominations.find_by(cycle: @cycle).book
  end

  test "cannot nominate a book already nominated by another member" do
    sign_in_as(@user)

    # handmaids_tale is already nominated by users(:two) via fixtures
    assert_no_difference "Nomination.count" do
      post cycle_nominations_path(@cycle), params: book_params(books(:handmaids_tale))
    end

    assert_response :redirect
    assert_equal "Book has already been taken", flash[:alert]
  end

  test "cannot nominate when no current cycle exists" do
    sign_in_as(@user)

    post cycle_nominations_path(cycles(:complete)), params: book_params

    assert_redirected_to clubs(:two)
    assert_equal "This club doesn't have an active cycle.", flash[:alert]
  end
end
