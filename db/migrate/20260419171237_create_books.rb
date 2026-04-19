class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :authors
      t.string :isbn
      t.string :google_books_id
      t.text :description
      t.string :cover_url
      t.string :publisher
      t.string :published_date

      t.timestamps
    end
    add_index :books, :google_books_id, unique: true
  end
end
