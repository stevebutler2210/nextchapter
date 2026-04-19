class Book < ApplicationRecord
  validates :title, presence: true
  validates :google_books_id, uniqueness: true, allow_nil: true
end
