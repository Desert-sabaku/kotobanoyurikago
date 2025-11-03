class MakeProposalsTermCaseInsensitive < ActiveRecord::Migration[8.1]
  def up
    say_with_time "Normalize proposal terms and resolve case-only duplicates per subject" do
      # Trim whitespace
      execute <<-SQL.squish
        UPDATE proposals SET term = trim(term) WHERE term IS NOT NULL;
      SQL

      # Find duplicates grouped by subject_id and lower(term)
      duplicates = select_all(<<-SQL.squish)
        SELECT subject_id, lower(term) AS l, array_agg(id ORDER BY id) AS ids
        FROM proposals
        GROUP BY subject_id, lower(term)
        HAVING count(*) > 1
      SQL

      duplicates.each do |row|
        ids = row["ids"].tr('{}', '').split(',')
        ids[1..-1].each do |dup_id|
          execute <<-SQL.squish
            UPDATE proposals
            SET term = term || '_dup' || #{dup_id}
            WHERE id = #{dup_id}
          SQL
        end
      end
    end

    # Remove existing composite index on (subject_id, term)
    if index_exists?(:proposals, [ :subject_id, :term ])
      remove_index :proposals, name: "index_proposals_on_subject_id_and_term_unique" rescue nil
    end

    # Create functional unique index on (subject_id, lower(term))
    execute <<-SQL.squish
      CREATE UNIQUE INDEX IF NOT EXISTS index_proposals_on_subject_id_and_lower_term_unique
      ON proposals (subject_id, LOWER(term));
    SQL
  end

  def down
    execute <<-SQL.squish
      DROP INDEX IF EXISTS index_proposals_on_subject_id_and_lower_term_unique;
    SQL
    unless index_exists?(:proposals, [ :subject_id, :term ])
      add_index :proposals, [ :subject_id, :term ], unique: true, name: "index_proposals_on_subject_id_and_term_unique"
    end
  end
end
