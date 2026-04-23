class AddNameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string

    # Set default name for existing users
    User.update_all(name: "") unless User.table_exists? && User.count.zero?

    # Now add the not null constraint
    change_column :users, :name, :string, null: false
  end
end
