class BookFindOrCreateService
  class << self
    def call(result)
      if result.google_books_id.present?
        existing_book = Book.find_by(google_books_id: result.google_books_id)
        return existing_book if existing_book
      end

      book = Book.create!(book_attributes(result))
      CacheCoverImageJob.perform_later(book.id)
      book
    end

    private

    def book_attributes(result)
      {
        google_books_id: result.google_books_id,
        title: result.title,
        authors: result.authors,
        isbn: result.isbn,
        description: result.description,
        cover_url: result.cover_url,
        publisher: result.publisher,
        published_date: result.published_date,
        page_count: result.page_count
      }
    end
  end
end
