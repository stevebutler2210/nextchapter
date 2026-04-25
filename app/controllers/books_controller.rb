class BooksController < ApplicationController
  def search
    @query = params[:query].to_s.strip

    if @query.length >= 3
      begin
        @results = BookLookupService.search(@query)
      rescue RuntimeError => e
        Rails.logger.warn("BookLookupService error: #{e.message}")
        @error = true
        @results = []
      end
    else
      @results = []
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
