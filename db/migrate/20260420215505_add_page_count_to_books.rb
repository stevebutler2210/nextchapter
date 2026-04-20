class AddPageCountToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :page_count, :integer
  end
end
