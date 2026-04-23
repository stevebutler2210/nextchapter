class HomeController < ApplicationController
  allow_unauthenticated_access only: :index

  def index
    redirect_to clubs_path if authenticated?
    @collage_books = Book.where(featured: true)
                         .order(Arel.sql("featured_index IS NULL, featured_index ASC, id ASC"))
                         .with_attached_cover_image
  end
end
