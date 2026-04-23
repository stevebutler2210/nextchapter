COLLAGE_ISBNS = [
  { isbn: "9780399563669", index: 0 },
  { isbn: "9781534312326", index: 1 },
  { isbn: "9781786890115", index: 2 },
  { isbn: "9780575093355", index: 3 },
  { isbn: "9780316556323", index: 4 },
  { isbn: "9780330534239", index: 5 },
  { isbn: "9781399614481", index: 6 },
  { isbn: "9781607067238", index: 7 },
  { isbn: "9780385490818", index: 8 }
].freeze

puts "Seeding collage books..."

COLLAGE_ISBNS.each do |entry|
  result = BookLookupService.find_by_isbn(entry[:isbn])

  unless result
    puts "  WARNING: no result from Google Books for ISBN #{entry[:isbn]} — skipping"
    next
  end

  book = if result.google_books_id.present?
    Book.find_by(google_books_id: result.google_books_id)
  end

  if book
    book.update!(featured: true, featured_index: entry[:index])
    puts "  Updated existing book as featured: #{book.title}"
  else
    book = Book.create!(
      google_books_id: result.google_books_id,
      title: result.title,
      authors: result.authors,
      isbn: result.isbn,
      description: result.description,
      cover_url: result.cover_url,
      publisher: result.publisher,
      published_date: result.published_date,
      page_count: result.page_count,
      featured: true,
      featured_index: entry[:index]
    )
    puts "  Created featured book: #{book.title}"
  end

  CacheCoverImageJob.perform_later(book.id)
end

puts "Collage books seeded: #{Book.where(featured: true).count} featured book(s)"
