class AddUniqueIndexToVotes < ActiveRecord::Migration[8.1]
  def change
    # Prevent a user from voting the same proposal more than once at the DB level
    unless index_exists?(:votes, [ :user_id, :proposal_id ], unique: true)
      add_index :votes, [ :user_id, :proposal_id ], unique: true, name: "index_votes_on_user_id_and_proposal_id_unique"
    end
  end
end
