class Club < ApplicationRecord
  belongs_to :created_by, class_name: "User"
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user

  validates :name, presence: true, uniqueness: true
end
