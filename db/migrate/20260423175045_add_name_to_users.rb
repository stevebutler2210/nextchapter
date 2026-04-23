class AddNameToUsers < ActiveRecord::Migration[8.1]
  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"
  end

  def up
    return unless table_exists?(:users)

    add_column :users, :name, :string
    MigrationUser.reset_column_information

    MigrationUser.where(name: [ nil, "" ]).find_each do |user|
      user.update_columns(name: derived_name_from_email(user.email_address))
    end

    change_column_null :users, :name, false
  end

  def down
    return unless table_exists?(:users)
    return unless column_exists?(:users, :name)

    remove_column :users, :name
  end

  private

  def derived_name_from_email(email_address)
    local_part = email_address.to_s.split("@").first.to_s
    candidate = local_part.tr("._-", " ").squish.titleize
    candidate.presence || "Unknown User"
  end
end
