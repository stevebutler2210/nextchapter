class CyclesController < ApplicationController
  before_action :set_cycle_and_club
  before_action :require_club_owner!, only: [ :close_nominations, :close_voting, :complete ]

  # Handle errors from invalid state transitions in the cycle model
  # TODO - extract transition logic to service and raise more specific
  # exceptions to avoid rescuing unexpected errors
  rescue_from RuntimeError do |error|
    redirect_to @club, alert: error.message, status: :see_other
  end

  def close_nominations
    @cycle.close_nominations!
    redirect_to @club, notice: "Nominations closed.", status: :see_other
  end

  def close_voting
    result = @cycle.close_voting_and_select_winner!

    message = result == :tied ?
      "Voting closed. A tie was randomly broken to select the winner." : "Voting closed."

    redirect_to @club, notice: message, status: :see_other
  end


  def complete
    ActiveRecord::Base.transaction do
      @cycle.complete!
      @club.cycles.create!(state: :nominating)
    end
    redirect_to @club, notice: "Reading cycle complete. Time to nominate again.", status: :see_other
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
