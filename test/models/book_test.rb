require "test_helper"

class BookTest < ActiveSupport::TestCase
  test "is valid with required fields" do
    book = books(:oathbringer)
    assert book.valid?
  end

  test "is invalid without a title" do
    book = books(:oathbringer)
    book.title = nil
    assert_not book.valid?
    assert_includes book.errors[:title], "can't be blank"
  end

  test "is invalid with a duplicate google_books_id" do
    duplicate = books(:oathbringer).dup
    duplicate.isbn = nil
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:google_books_id], "has already been taken"
  end

  test "is valid with a nil google_books_id" do
    book = books(:oathbringer)
    book.google_books_id = nil
    assert book.valid?
  end
end
