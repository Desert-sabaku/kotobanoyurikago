class AddParentCommentFkToComments < ActiveRecord::Migration[8.1]
  def change
    # Add a self-referential foreign key from comments.parent_comment_id to comments.id
    # Use ON DELETE SET NULL so that deleting a parent comment doesn't cascade-delete replies.
    unless foreign_key_exists?(:comments, :comments, column: :parent_comment_id)
      add_foreign_key :comments, :comments, column: :parent_comment_id, on_delete: :nullify
    end
  end
end
