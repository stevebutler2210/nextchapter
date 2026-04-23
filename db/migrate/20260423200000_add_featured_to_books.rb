class AddFeaturedToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :featured, :boolean, default: false, null: false
  end
end
