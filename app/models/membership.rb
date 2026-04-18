class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :club

  enum :role, { owner: "owner", member: "member" }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :club_id }
end
