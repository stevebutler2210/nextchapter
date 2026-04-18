class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.string :role, null: false

      t.timestamps
    end

    add_index :memberships, [ :user_id, :club_id ], unique: true
  end
end
