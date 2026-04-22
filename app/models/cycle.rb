class Cycle < ApplicationRecord
  belongs_to :club
  belongs_to :winning_nomination, class_name: "Nomination", optional: true
  has_many :nominations, dependent: :destroy
  has_many :votes, dependent: :destroy

  enum :state, { nominating: "nominating", voting: "voting", reading: "reading", complete: "complete" }

  validates :state, presence: true

  validates :club_id, uniqueness: {
    conditions: -> { where.not(state: :complete) },
    message: "can only have one active cycle at a time"
  }

  validates :winning_nomination, presence: true, if: -> { reading? }

  # Transition methods - each raises on invalid transition
  def close_nominations!
    raise "Cannot advance to voting from #{state}" unless nominating?
    raise "Cannot advance to voting without any nominations" if nominations.none?
    update!(state: :voting)
  end

  def close_voting_and_select_winner!
    raise "Cannot close voting from #{state}" unless voting?

    counts = vote_counts_by_nomination_id
    raise "Cannot close voting without any votes" if counts.values.all?(&:zero?)

    max_votes = counts.values.max
    vote_leaders = counts.select { |_id, votes| votes == max_votes }.keys
    winner_id = vote_leaders.sample

    update!(winning_nomination_id: winner_id, state: :reading)
    vote_leaders.many? ? :tied : :clear_winner
  end

  def complete!
    raise "Cannot complete from #{state}" unless reading?
    update!(state: :complete)
  end

  def vote_counts_by_nomination_id
    nominations.left_joins(:votes).group("nominations.id").count("votes.id")
  end
end
