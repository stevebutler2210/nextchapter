class CreateReadingLogEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :reading_log_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :cycle, null: false, foreign_key: true
      t.string :state, null: false
      t.integer :page_reached
      t.text :note

      t.timestamps
    end

    add_index :reading_log_entries, [ :user_id, :cycle_id ]
    add_index :reading_log_entries, [ :cycle_id, :created_at ]
  end
end
