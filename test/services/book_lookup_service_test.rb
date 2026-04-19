require "test_helper"

class BookLookupServiceTest < ActiveSupport::TestCase
  OATHBRINGER_ITEM = {
    "id" => "1xfwCgAAQBAJ",
    "volumeInfo" => {
      "title" => "Oathbringer",
      "authors" => [ "Brandon Sanderson" ],
      "industryIdentifiers" => [
        { "type" => "ISBN_13", "identifier" => "9780575093355" }
      ],
      "imageLinks" => { "thumbnail" => "https://books.google.com/thumbnail.jpg" },
      "publisher" => "Tor Books",
      "publishedDate" => "2017"
    }
  }.freeze

  def stub_connection(status, body)
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get("/") { [ status, { "Content-Type" => "application/json" }, body ] }
    end
    Faraday.new do |builder|
      builder.adapter :test, stubs
    end
  end

  test "successful search returns array of Results with correct fields" do
    body = JSON.generate({ "items" => [ OATHBRINGER_ITEM ] })
    connection = stub_connection(200, body)

    results = BookLookupService.search("Oathbringer", connection: connection)

    assert_equal 1, results.length
    result = results.first
    assert_instance_of BookLookupService::Result, result
    assert_equal "Oathbringer", result.title
    assert_equal "Brandon Sanderson", result.authors
    assert_equal "9780575093355", result.isbn
  end

  test "search returns empty array when no items" do
    body = JSON.generate({ "kind" => "books#volumes", "totalItems" => 0 })
    connection = stub_connection(200, body)

    results = BookLookupService.search("zzznoresults", connection: connection)

    assert_equal [], results
  end

  test "search raises RuntimeError on non-200 response" do
    connection = stub_connection(429, "")

    assert_raises(RuntimeError) do
      BookLookupService.search("anything", connection: connection)
    end
  end
end
