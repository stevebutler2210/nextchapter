class CreateNominations < ActiveRecord::Migration[8.1]
  def change
    create_table :nominations do |t|
      t.references :book, null: false, foreign_key: true
      t.references :cycle, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :nominations, [ :cycle_id, :user_id ], unique: true
    add_index :nominations, [ :cycle_id, :book_id ], unique: true
  end
end
