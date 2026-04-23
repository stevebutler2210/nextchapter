class ReadingLogEntriesController < ApplicationController
  before_action :set_cycle_and_club

  def create
    @reading_log_entry = @cycle.reading_log_entries.new(reading_log_entry_params)
    @reading_log_entry.user = Current.user

    if @reading_log_entry.save
      @reading_log_entry = ReadingLogEntry.new

      respond_to do |format|
        format.html { redirect_to @club }
        format.turbo_stream { render_reading_frame }
      end
    else
      respond_to do |format|
        format.html { redirect_to @club, alert: @reading_log_entry.errors.full_messages.to_sentence }
        format.turbo_stream { render_reading_frame(status: :unprocessable_entity) }
      end
    end
  end

  private

  def set_cycle_and_club
    @cycle = Cycle.joins(club: :memberships)
      .where(memberships: { user_id: Current.user.id })
      .includes(:club, winning_nomination: :book)
      .find(params[:cycle_id])

    @club = @cycle.club
  rescue ActiveRecord::RecordNotFound
    head :forbidden
  end

  def reading_log_entry_params
    entry = params.require(:reading_log_entry).permit(:note, :state, :finished_flag)

    state = if entry[:finished_flag] == "1"
      "finished"
    else
      entry[:state]
    end

    entry.except(:finished_flag).merge(state: state)
  end

  def render_reading_frame(status: :ok)
    render turbo_stream: turbo_stream.replace(
      helpers.dom_id(@cycle, :reading_log_entries),
      partial: "clubs/reading_log_entries_frame",
      locals: {
        cycle: @cycle,
        reading_log_entry: @reading_log_entry,
        reading_log_entries: current_user_entries
      }
    ), status: status
  end

  def current_user_entries
    @cycle.reading_log_entries
      .where(user: Current.user)
      .order(created_at: :desc)
  end
end
