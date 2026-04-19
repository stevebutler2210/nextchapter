require "test_helper"

class CacheCoverImageJobTest < ActiveSupport::TestCase
  setup do
    @book = books(:oathbringer)
    @book.cover_image.purge if @book.cover_image.attached?
  end

  test "attaches cover_image when book has a cover_url and no existing attachment" do
    fixture_file = File.open(Rails.root.join("test/fixtures/files/cover.jpg"), "rb")
    job = CacheCoverImageJob.new

    job.stub(:download, fixture_file) do
      job.perform(@book.id)
    end

    assert @book.reload.cover_image.attached?
  ensure
    fixture_file.close
  end

  test "skips download when cover_image is already attached" do
    File.open(Rails.root.join("test/fixtures/files/cover.jpg"), "rb") do |file|
      @book.cover_image.attach(io: file, filename: "cover.jpg", content_type: "image/jpeg")
    end

    called = false
    job = CacheCoverImageJob.new
    job.stub(:download, ->(_url) { called = true }) do
      job.perform(@book.id)
    end

    assert_not called
  end

  test "skips download when cover_url is blank" do
    @book.update!(cover_url: nil)

    called = false
    job = CacheCoverImageJob.new
    job.stub(:download, ->(_url) { called = true }) do
      job.perform(@book.id)
    end

    assert_not called
    assert_not @book.reload.cover_image.attached?
  end
end
