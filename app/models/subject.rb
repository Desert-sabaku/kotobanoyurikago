class Subject < ApplicationRecord
  belongs_to :user
  has_many :proposals, dependent: :destroy

  validates :title, presence: true, uniqueness: true
end
