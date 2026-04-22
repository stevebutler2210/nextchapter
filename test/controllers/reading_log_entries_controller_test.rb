require "test_helper"

class ReadingLogEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @member = users(:one)
    @club_member = users(:two)
    @non_member = users(:three)

    @club = Club.create!(
      name: "Reading club #{SecureRandom.hex(4)}",
      description: "Club for reading log tests",
      created_by: @member
    )
    @club.memberships.create!(user: @member, role: :owner)
    @club.memberships.create!(user: @club_member, role: :member)

    @cycle = @club.cycles.create!(state: :voting)
    winning_nomination = @cycle.nominations.create!(user: @member, book: books(:the_hobbit))
    @cycle.update!(winning_nomination: winning_nomination, state: :reading)

    @nominating_club = Club.create!(
      name: "Nominating club #{SecureRandom.hex(4)}",
      description: "Club for invalid state tests",
      created_by: @member
    )
    @nominating_club.memberships.create!(user: @member, role: :owner)
    @nominating_cycle = @nominating_club.cycles.create!(state: :nominating)
  end

  test "member can create reading log entry" do
    sign_in_as(@club_member)

    assert_difference "ReadingLogEntry.count", 1 do
      post cycle_reading_log_entries_path(@cycle), params: {
        reading_log_entry: {
          state: "started",
          page_reached: 12,
          note: "Strong opening chapter"
        }
      }
    end

    assert_redirected_to @club
    entry = ReadingLogEntry.last
    assert_equal @club_member, entry.user
    assert_equal @cycle, entry.cycle
    assert_equal "started", entry.state
    assert_equal 12, entry.page_reached
    assert_equal "Strong opening chapter", entry.note
  end

  test "creation is rejected when cycle is not in reading state" do
    sign_in_as(@member)

    assert_no_difference "ReadingLogEntry.count" do
      post cycle_reading_log_entries_path(@nominating_cycle), params: {
        reading_log_entry: {
          state: "started",
          page_reached: 10,
          note: "Should fail"
        }
      }
    end

    assert_redirected_to @nominating_club
    assert_equal "Reading log is not open for this cycle", flash[:alert]
  end

  test "non-member gets forbidden" do
    sign_in_as(@non_member)

    assert_no_difference "ReadingLogEntry.count" do
      post cycle_reading_log_entries_path(@cycle), params: {
        reading_log_entry: {
          state: "started",
          page_reached: 9,
          note: "Should not be allowed"
        }
      }
    end

    assert_response :forbidden
  end

  test "page reached cannot exceed winning book page count" do
    sign_in_as(@member)

    assert_no_difference "ReadingLogEntry.count" do
      post cycle_reading_log_entries_path(@cycle), params: {
        reading_log_entry: {
          state: "progressed",
          page_reached: 999,
          note: "Past end"
        }
      }
    end

    assert_redirected_to @club
    assert_equal "Page reached cannot be greater than total pages (366)", flash[:alert]
  end
end
