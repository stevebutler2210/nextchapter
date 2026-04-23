class InvitesController < ApplicationController
  def show
    @club = Club.find_signed(params[:signed_id])

    if @club.nil?
      render "invites/invalid", status: :not_found
      return
    end

    if @club.memberships.exists?(user: Current.user)
      redirect_to club_path(@club), alert: "You're already a member of this club."
      return
    end

    @club.memberships.create!(user: Current.user, role: :member)
    BroadcastClubMembersJob.perform_later(@club.id)
    redirect_to club_path(@club), notice: "You've joined #{@club.name}."
  end

  private
    def request_authentication
      flash[:alert] = "Please sign in to accept the invite."
      super
    end
end
