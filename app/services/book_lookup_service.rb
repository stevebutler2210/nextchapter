class BookLookupService
  BASE_URL = "https://www.googleapis.com/books/v1/volumes".freeze

  Result = Data.define(
    :google_books_id, :title, :authors, :isbn,
    :description, :cover_url, :publisher, :published_date
  ) do
    def cover_image_url
      cover_url
    end
  end


  class << self
    def search(query, connection: default_connection)
      response = fetch({ q: query }, connection: connection)
      items = response.fetch("items", [])

      items.map { |item| build_book_result(item) }
    end

    def find_by_isbn(isbn, connection: default_connection)
      search("isbn:#{isbn}", connection: connection).first
    end

    private

    def default_connection
      Faraday.new(BASE_URL)
    end

    def fetch(params, connection:)
      response = connection.get do |request|
        request.params["q"] = params[:q]
        request.params["key"] = Rails.application.credentials.google_books_api_key
      end

      raise RuntimeError, response.status.to_s if response.status != 200

      JSON.parse(response.body)
    end

    def build_book_result(item)
      volume_info = item.fetch("volumeInfo", {})

      Result.new(
        google_books_id: item["id"],
        title: volume_info["title"],
        authors: parse_authors(volume_info),
        isbn: parse_isbn(volume_info),
        description: volume_info["description"],
        cover_url: volume_info.dig("imageLinks", "thumbnail"),
        publisher: volume_info["publisher"],
        published_date: volume_info["publishedDate"]
      )
    end

    def parse_authors(volume_info)
      authors = volume_info["authors"]
      return nil unless authors.is_a?(Array) && authors.any?

      authors.join(", ")
    end

    def parse_isbn(volume_info)
      identifiers = volume_info["industryIdentifiers"]
      return nil unless identifiers.is_a?(Array)

      isbn_13 = identifiers.find { |identifier| identifier["type"] == "ISBN_13" }
      return isbn_13["identifier"] if isbn_13

      isbn_10 = identifiers.find { |identifier| identifier["type"] == "ISBN_10" }
      isbn_10&.fetch("identifier", nil)
    end
  end
end
