class ReadingLogEntry < ApplicationRecord
  belongs_to :user
  belongs_to :cycle

  enum :state, {
    started: "started",
    progressed: "progressed",
    finished: "finished"
  }

  validates :state, presence: true
  validates :page_reached,
    numericality: { only_integer: true, greater_than: 0 },
    allow_nil: true

  validate :cycle_must_be_in_reading_state
  validate :page_reached_cannot_exceed_book_page_count

  private

  def cycle_must_be_in_reading_state
    return unless cycle

    errors.add(:base, "Reading log is not open for this cycle") unless cycle.reading?
  end

  def page_reached_cannot_exceed_book_page_count
    return if page_reached.nil?

    page_count = cycle&.winning_nomination&.book&.page_count
    return if page_count.nil?
    return if page_reached <= page_count

    errors.add(:page_reached, "cannot be greater than total pages (#{page_count})")
  end
end
