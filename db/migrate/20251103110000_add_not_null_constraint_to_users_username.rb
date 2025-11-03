class AddNotNullConstraintToUsersUsername < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    # Ensure no NULL usernames exist: populate with a unique fallback using email prefix + id
    say_with_time "Populate NULL usernames with fallback values" do
      execute <<-SQL.squish
        UPDATE users
        SET username = (split_part(email, '@', 1) || '_' || id::text)
        WHERE username IS NULL
      SQL
    end

    # Add NOT NULL constraint
    change_column_null :users, :username, false
  end

  def down
    # Revert NOT NULL constraint (keep data as-is)
    change_column_null :users, :username, true
  end
end
