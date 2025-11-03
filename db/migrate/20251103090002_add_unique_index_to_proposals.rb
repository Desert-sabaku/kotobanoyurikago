class AddUniqueIndexToProposals < ActiveRecord::Migration[8.1]
  def change
    unless index_exists?(:proposals, [ :subject_id, :term ], unique: true)
      add_index :proposals, [ :subject_id, :term ], unique: true, name: "index_proposals_on_subject_id_and_term_unique"
    end
  end
end
