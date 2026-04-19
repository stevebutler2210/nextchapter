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

  test "cover_image_url returns cover_url when no attachment" do
    book = books(:oathbringer)
    assert_equal book.cover_url, book.cover_image_url
  end

  test "cover_image_url returns nil when no attachment and no cover_url" do
    book = books(:oathbringer)
    book.cover_url = nil
    assert_nil book.cover_image_url
  end

  test "cover_image_url returns rails blob path when cover_image is attached" do
    book = books(:oathbringer)
    book.cover_image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/cover.jpg")),
      filename: "cover.jpg",
      content_type: "image/jpeg"
    )
    assert_match /\/rails\/active_storage\//, book.cover_image_url
  end
end
