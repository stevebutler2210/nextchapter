class BroadcastVoteTallyJob < ApplicationJob
  queue_as :default

  def perform(nomination_id)
    nomination = Nomination.find(nomination_id)
    cycle_id = nomination.cycle_id

    Turbo::StreamsChannel.broadcast_replace_to(
      "cycle_#{cycle_id}_votes",
      target: "nomination_#{nomination_id}_count",
      partial: "nominations/vote_count",
      locals: { nomination: nomination }
    )

    Turbo::StreamsChannel.broadcast_replace_to(
      "cycle_#{cycle_id}_votes",
      target: "voting_no_votes_notice",
      partial: "nominations/voting_no_votes_notice",
      locals: {
        has_nominations: Nomination.where(cycle_id: cycle_id).exists?,
        has_votes: Vote.where(cycle_id: cycle_id).exists?
      }
    )
  end
end
