class VotesController < ApplicationController
  before_action :set_nomination, only: [ :create ]

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
    @vote = Vote.find(params[:id])
    @nomination = @vote.nomination
    @vote.destroy
    @nomination.reload
    BroadcastVoteTallyJob.perform_later(@nomination.id)

    respond_to do |format|
      format.html { redirect_to @nomination.cycle.club }
      format.turbo_stream
    end
  end

  private

  def set_nomination
    @nomination = Nomination.includes(:cycle).find(params[:nomination_id])
  end
end
