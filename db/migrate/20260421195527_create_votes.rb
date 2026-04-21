class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :nomination, null: false, foreign_key: true
      t.references :cycle, null: false, foreign_key: true

      t.timestamps
    end

    add_index :votes, [ :user_id, :cycle_id ], unique: true
  end
end
