class MakeSubjectsTitleCaseInsensitive < ActiveRecord::Migration[8.1]
  def up
    say_with_time "Normalize subject titles and resolve case-only duplicates" do
      # Trim whitespace
      execute <<-SQL.squish
        UPDATE subjects SET title = trim(title) WHERE title IS NOT NULL;
      SQL

      # Find case-insensitive duplicates and append unique suffix to later rows
      duplicates = select_all(<<-SQL.squish)
        SELECT lower(title) AS l, array_agg(id ORDER BY id) AS ids
        FROM subjects
        GROUP BY lower(title)
        HAVING count(*) > 1
      SQL

      duplicates.each do |row|
        ids = row["ids"].tr('{}', '').split(',')
        # keep first id as canonical, modify others
        ids[1..-1].each do |dup_id|
          execute <<-SQL.squish
            UPDATE subjects
            SET title = title || '_dup' || #{dup_id}
            WHERE id = #{dup_id}
          SQL
        end
      end
    end

    # Drop existing unique index on title (if any) and create functional unique index on lower(title)
    if index_exists?(:subjects, :title)
      remove_index :subjects, column: :title, name: "index_subjects_on_title_unique" rescue nil
    end

    execute <<-SQL.squish
      CREATE UNIQUE INDEX IF NOT EXISTS index_subjects_on_lower_title_unique
      ON subjects (LOWER(title));
    SQL
  end

  def down
    execute <<-SQL.squish
      DROP INDEX IF EXISTS index_subjects_on_lower_title_unique;
    SQL
    # Recreate simple unique index on title (case-sensitive)
    unless index_exists?(:subjects, :title)
      add_index :subjects, :title, unique: true, name: "index_subjects_on_title_unique"
    end
  end
end
