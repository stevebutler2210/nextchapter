require "open-uri"

class CacheCoverImageJob < ApplicationJob
  queue_as :default

  def perform(book_id)
    book = Book.find_by(id: book_id)
    return unless book
    return if book.cover_url.blank?
    return if book.cover_image.attached?

    file = download(book.cover_url)
    filename = URI.parse(book.cover_url).path.split("/").last

    book.cover_image.attach(
      io: file,
      filename: filename,
      content_type: "image/jpeg"
    )
  rescue StandardError => e
    Rails.logger.error("CacheCoverImageJob failed for book_id=#{book_id}: #{e.message}")
    nil
  end

  private

  def download(url)
    URI.open(url)
  end
end
