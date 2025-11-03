class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :proposal

  # Self-referential association for threaded comments
  belongs_to :parent_comment, class_name: "Comment", optional: true, inverse_of: :replies
  has_many :replies, class_name: "Comment", foreign_key: :parent_comment_id, dependent: :nullify, inverse_of: :parent_comment

  validates :body, presence: true
end
