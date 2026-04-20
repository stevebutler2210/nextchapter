class Nomination < ApplicationRecord
  belongs_to :book
  belongs_to :cycle
  belongs_to :user

  validates :user_id, uniqueness: { scope: :cycle_id }
  validates :book_id, uniqueness: { scope: :cycle_id }
end
