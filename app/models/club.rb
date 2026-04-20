class Club < ApplicationRecord
  belongs_to :created_by, class_name: "User"
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :cycles, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def owned_by?(user)
    memberships.find_by(user_id: user.id)&.owner?
  end

  def current_cycle
    cycles.find_by(state: [ :nominating, :voting, :reading ])
  end
end
