class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :lockable

  # foreign keys on child records are NOT NULL, so nullifying would break
  # the DB constraint. Prevent deleting a user who still owns records and
  # surface an error instead of trying to set user_id = NULL.
  has_many :subjects, dependent: :restrict_with_error
  has_many :proposals, dependent: :restrict_with_error
  has_many :votes, dependent: :restrict_with_error
  has_many :comments, dependent: :restrict_with_error

  # username must be present and unique
  validates :username, presence: true, uniqueness: true
end
