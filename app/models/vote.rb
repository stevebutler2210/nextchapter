class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :nomination
  belongs_to :cycle

  before_validation :set_cycle_from_nomination

  validates :user_id, uniqueness: {
    scope: :cycle_id,
    message: "has already voted in this cycle"
  }

  validate :cycle_must_be_in_voting_state

  private

  def set_cycle_from_nomination
    self.cycle = nomination&.cycle
  end

  def cycle_must_be_in_voting_state
    return unless cycle
    errors.add(:base, "Voting is not open for this cycle") unless cycle.voting?
  end
end
