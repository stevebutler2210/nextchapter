class CreateCycles < ActiveRecord::Migration[8.1]
  def change
    create_table :cycles do |t|
      t.references :club, null: false, foreign_key: true
      t.string :state, default: "nominating", null: false

      t.timestamps
    end

    # Partial unique index: only one active (non-complete) cycle per club
    add_index :cycles, :club_id, unique: true, where: "state != 'complete'", name: "index_cycles_on_club_id_where_state_not_complete"
  end
end
