class ModifyWinningNominationForeignKey < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :cycles, column: :winning_nomination_id
    add_foreign_key :cycles, :nominations, column: :winning_nomination_id, on_delete: :nullify
  end
end
