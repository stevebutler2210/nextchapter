class BroadcastClubMembersJob < ApplicationJob
  queue_as :default

  def perform(club_id)
    club = Club.find(club_id)

    Turbo::StreamsChannel.broadcast_replace_to(
      "club_#{club.id}",
      target: "club_members_#{club.id}",
      partial: "clubs/member_avatars",
      locals: {
        club: club,
        memberships: club.memberships.includes(:user).order(:id)
      }
    )
  end
end
