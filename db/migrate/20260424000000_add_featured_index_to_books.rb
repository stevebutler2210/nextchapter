class AddFeaturedIndexToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :featured_index, :integer
  end
end
