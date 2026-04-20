require "test_helper"

class BookFindOrCreateServiceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    clear_enqueued_jobs
  end

  test "finds existing book by google_books_id without dispatching cache job" do
    existing_book = books(:oathbringer)
    result = BookLookupService::Result.new(
      google_books_id: existing_book.google_books_id,
      title: "Different Title",
      authors: "Different Author",
      isbn: "0000000000000",
      description: "Different description",
      cover_url: "https://example.com/different.jpg",
      publisher: "Different Publisher",
      published_date: "2020-01-01",
      page_count: 999
    )

    book = nil
    assert_no_enqueued_jobs only: CacheCoverImageJob do
      book = BookFindOrCreateService.call(result)
    end

    assert_equal existing_book.id, book.id
    assert_equal "Oathbringer", book.title
  end

  test "creates new book and dispatches cache job" do
    result = BookLookupService::Result.new(
      google_books_id: "new_google_books_id_123",
      title: "New Book",
      authors: "A. Author",
      isbn: "9780000000001",
      description: "A description",
      cover_url: "https://example.com/new-book.jpg",
      publisher: "New Publisher",
      published_date: "2026-04-20",
      page_count: 250
    )

    created_book = nil
    assert_enqueued_jobs 1, only: CacheCoverImageJob do
      created_book = BookFindOrCreateService.call(result)
    end

    assert created_book.persisted?
    assert_equal result.google_books_id, created_book.google_books_id

    cache_job = enqueued_jobs.find { |job| job[:job] == CacheCoverImageJob }
    assert_not_nil cache_job
    assert_equal [ created_book.id ], cache_job[:args]
  end
end
