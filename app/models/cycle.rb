class Cycle < ApplicationRecord
  belongs_to :club
  has_many :nominations, dependent: :destroy
  has_many :votes, dependent: :destroy

  enum :state, { nominating: "nominating", voting: "voting", reading: "reading", complete: "complete" }

  validates :state, presence: true

  validates :club_id, uniqueness: {
    conditions: -> { where.not(state: :complete) },
    message: "can only have one active cycle at a time"
  }

  # Transition methods - each raises on invalid transition
  def advance_to_voting!
    raise "Cannot advance to voting from #{state}" unless nominating?
    update!(state: :voting)
  end

  def advance_to_reading!
    raise "Cannot advance to reading from #{state}" unless voting?
    update!(state: :reading)
  end

  def complete!
    raise "Cannot complete from #{state}" unless reading?
    update!(state: :complete)
  end
end
