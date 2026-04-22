class CyclesController < ApplicationController
  before_action :set_cycle_and_club
  before_action :require_club_owner!, only: [ :close_voting ]

  def close_voting
    result = @cycle.close_voting_and_select_winner!

    message = result == :tied ?
      "Voting closed. A tie was randomly broken to select the winner." : "Voting closed."

    redirect_to @club, notice: message
  rescue RuntimeError => error
    redirect_to @club, alert: error.message
  end

  private

  def set_cycle_and_club
    @cycle = Cycle.joins(club: :memberships)
      .where(memberships: { user_id: Current.user.id })
      .includes(:club)
      .find(params[:id])

    @club = @cycle.club
  end

  def require_club_owner!
    head :forbidden unless @club.owned_by?(Current.user)
  end
end
