require "test_helper"

class NominationTest < ActiveSupport::TestCase
  test "is valid with valid associations" do
    nomination = nominations(:oathbringer)

    assert nomination.valid?
  end

  test "rejects duplicate nomination for same user and cycle" do
    existing_nomination = nominations(:oathbringer)
    duplicate = Nomination.new(
      cycle: existing_nomination.cycle,
      user: existing_nomination.user,
      book: books(:handmaids_tale)
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "rejects duplicate book nomination in same cycle from different user" do
    existing_nomination = nominations(:oathbringer)
    duplicate = Nomination.new(
      cycle: existing_nomination.cycle,
      user: users(:two),
      book: existing_nomination.book
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:book_id], "has already been taken"
  end
end
