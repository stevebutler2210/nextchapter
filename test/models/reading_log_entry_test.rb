require "test_helper"

class ReadingLogEntryTest < ActiveSupport::TestCase
  setup do
    @owner = users(:one)
    @member = users(:two)

    @club = Club.create!(
      name: "Reading log model club #{SecureRandom.hex(4)}",
      description: "Model test club",
      created_by: @owner
    )

    @club.memberships.create!(user: @owner, role: :owner)
    @club.memberships.create!(user: @member, role: :member)

    @reading_cycle = @club.cycles.create!(state: :voting)
    winner = @reading_cycle.nominations.create!(user: @owner, book: books(:the_hobbit))
    @reading_cycle.update!(winning_nomination: winner, state: :reading)
  end

  test "is valid with reading cycle and valid attributes" do
    entry = ReadingLogEntry.new(
      user: @member,
      cycle: @reading_cycle,
      state: :started,
      page_reached: 10,
      note: "Strong opening"
    )

    assert entry.valid?
  end

  test "is invalid when cycle is not in reading state" do
    non_reading_club = Club.create!(
      name: "Non reading club #{SecureRandom.hex(4)}",
      description: "Club with a nominating cycle",
      created_by: @owner
    )
    non_reading_club.memberships.create!(user: @owner, role: :owner)
    non_reading_club.memberships.create!(user: @member, role: :member)

    non_reading_cycle = non_reading_club.cycles.create!(state: :nominating)

    entry = ReadingLogEntry.new(
      user: @member,
      cycle: non_reading_cycle,
      state: :started,
      page_reached: 10
    )

    assert_not entry.valid?
    assert_includes entry.errors[:base], "Reading log is not open for this cycle"
  end

  test "is invalid when page reached exceeds winning book page count" do
    entry = ReadingLogEntry.new(
      user: @member,
      cycle: @reading_cycle,
      state: :progressed,
      page_reached: 999
    )

    assert_not entry.valid?
    assert_includes entry.errors[:page_reached], "cannot be greater than total pages (366)"
  end

  test "allows page reached when winning book has no page count" do
    no_count_book = Book.create!(
      title: "No Count Book #{SecureRandom.hex(3)}",
      authors: "Anon",
      page_count: nil
    )

    another_club = Club.create!(
      name: "No count reading club #{SecureRandom.hex(4)}",
      description: "Club for nil page count",
      created_by: @owner
    )
    another_club.memberships.create!(user: @owner, role: :owner)
    another_club.memberships.create!(user: @member, role: :member)

    another_cycle = another_club.cycles.create!(state: :voting)
    winner = another_cycle.nominations.create!(user: @owner, book: no_count_book)
    another_cycle.update!(winning_nomination: winner, state: :reading)

    entry = ReadingLogEntry.new(
      user: @member,
      cycle: another_cycle,
      state: :progressed,
      page_reached: 999
    )

    assert entry.valid?
  end

  test "encrypts note at rest" do
    plain_note = "This is private"

    entry = ReadingLogEntry.create!(
      user: @member,
      cycle: @reading_cycle,
      state: :finished,
      note: plain_note
    )

    raw_note_value = ReadingLogEntry.connection.select_value(
      "SELECT note FROM reading_log_entries WHERE id = #{entry.id}"
    )

    assert_equal plain_note, entry.reload.note
    assert_not_equal plain_note, raw_note_value
  end
end
