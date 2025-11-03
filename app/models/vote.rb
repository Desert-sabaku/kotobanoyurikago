class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :proposal

  # Prevent duplicate votes at the application level as well
  validates :user_id, uniqueness: { scope: :proposal_id }
end
