class VotesController < ApplicationController
  before_action :set_nomination, only: [ :create ]
  before_action :set_vote, only: [ :destroy ]
  before_action :require_vote_owner!, only: [ :destroy ]

  def create
    vote = Vote.new(user: Current.user, nomination: @nomination)

    if vote.save
      @vote = vote
      BroadcastVoteTallyJob.perform_later(@nomination.id)
      respond_to do |format|
        format.html { redirect_to @nomination.cycle.club }
        format.turbo_stream
      end
    else
      redirect_to @nomination.cycle.club,
        alert: vote.errors.full_messages.to_sentence
    end
  end

  def destroy
    @nomination = @vote.nomination
    @vote.destroy
    BroadcastVoteTallyJob.perform_later(@nomination.id)

    respond_to do |format|
      format.html { redirect_to @nomination.cycle.club }
      format.turbo_stream
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to clubs_path, alert: "Vote not found"
  end

  private

  def set_nomination
    @nomination = Nomination.includes(:cycle).find(params[:nomination_id])
  end

  def set_vote
    @vote = Vote.find(params[:id])
  end

  def require_vote_owner!
    head :forbidden unless @vote.user_id == Current.user.id
  end
end
