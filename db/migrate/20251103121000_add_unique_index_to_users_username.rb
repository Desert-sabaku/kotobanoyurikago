class AddUniqueIndexToUsersUsername < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  INDEX_NAME = "index_users_on_username_unique"

  def up
    # Make sure there are no case where the same username appears multiple times
    say_with_time "Deduplicate usernames (append _dup<ID> to duplicates)" do
      execute <<-SQL.squish
        WITH numbered AS (
          SELECT id, username, row_number() OVER (PARTITION BY username ORDER BY id) AS rn
          FROM users
          WHERE username IS NOT NULL
        )
        UPDATE users u
        SET username = u.username || '_dup' || u.id::text
        FROM numbered n
        WHERE u.id = n.id AND n.rn > 1
      SQL
    end

    say_with_time "Add unique index on users.username concurrently" do
      add_index :users, :username, unique: true, name: INDEX_NAME, algorithm: :concurrently
    end
  end

  def down
    remove_index :users, name: INDEX_NAME, algorithm: :concurrently
  end
end
