class NominationsController < ApplicationController
  before_action :set_cycle_and_club

  def create
    book = BookFindOrCreateService.call(book_result_from_params)
    nomination = @cycle.nominations.find_or_initialize_by(user: Current.user)
    nomination.book = book

    if nomination.save
      @nomination = nomination
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @club }
      end
    else
      redirect_to @club, alert: nomination.errors.full_messages.to_sentence
    end
  end

  private

  def set_cycle_and_club
    @cycle = Cycle.find(params[:cycle_id])
    @club = @cycle.club

    unless @cycle.nominating?
      redirect_to @club, alert: "This club doesn't have an active cycle."
    end
  end

  def book_result_from_params
    BookLookupService::Result.new(
      google_books_id: params[:google_books_id],
      title: params[:title],
      authors: params[:authors],
      isbn: params[:isbn],
      description: params[:description],
      cover_url: params[:cover_url],
      publisher: params[:publisher],
      published_date: params[:published_date],
      page_count: params[:page_count]
    )
  end
end
