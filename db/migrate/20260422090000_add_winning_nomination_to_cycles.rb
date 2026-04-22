class AddWinningNominationToCycles < ActiveRecord::Migration[8.1]
  def change
    add_reference :cycles, :winning_nomination, null: true, foreign_key: { to_table: :nominations }
  end
end
