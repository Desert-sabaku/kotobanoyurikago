class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :lockable

  has_many :subjects, dependent: :nullify
  has_many :proposals, dependent: :nullify
  has_many :votes, dependent: :nullify
  has_many :comments, dependent: :nullify

  # username must be present and unique
  validates :username, presence: true, uniqueness: true
end
