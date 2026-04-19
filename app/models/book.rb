class Book < ApplicationRecord
  validates :title, presence: true
  validates :google_books_id, uniqueness: true, allow_nil: true

  has_one_attached :cover_image

  def cover_image_url
    if cover_image.attached?
      Rails.application.routes.url_helpers.rails_blob_url(cover_image, only_path: true)
    elsif cover_url.present?
      cover_url
    else
      nil
    end
  end
end
