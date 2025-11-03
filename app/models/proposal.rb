class Proposal < ApplicationRecord
  belongs_to :subject
  belongs_to :user
  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :term, presence: true
  validates :term, uniqueness: { scope: :subject_id }
end
