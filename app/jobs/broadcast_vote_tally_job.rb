class BroadcastVoteTallyJob < ApplicationJob
  queue_as :default

  def perform(nomination_id)
    nomination = Nomination.find(nomination_id)

    Turbo::StreamsChannel.broadcast_replace_to(
      "cycle_#{nomination.cycle_id}_votes",
      target: "nomination_#{nomination_id}_count",
      partial: "nominations/vote_count",
      locals: { nomination: nomination }
    )
  end
end
