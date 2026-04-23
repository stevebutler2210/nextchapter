class BroadcastVoteTallyJob < ApplicationJob
  queue_as :default

  def perform(nomination_id)
    nomination = Nomination.find(nomination_id)
    nominations = nomination.cycle.nominations.includes(:votes)

    Turbo::StreamsChannel.broadcast_replace_to(
      "cycle_#{nomination.cycle_id}_votes",
      target: "nomination_#{nomination_id}_count",
      partial: "nominations/vote_count",
      locals: { nomination: nomination }
    )

    Turbo::StreamsChannel.broadcast_replace_to(
      "cycle_#{nomination.cycle_id}_votes",
      target: "voting_no_votes_notice",
      partial: "nominations/voting_no_votes_notice",
      locals: { nominations: nominations }
    )
  end
end
