class Nomination < ApplicationRecord
  belongs_to :book
  belongs_to :cycle
  belongs_to :user

  validates :user_id, uniqueness: { scope: :cycle_id }
  validates :book_id, uniqueness: { scope: :cycle_id }

  after_create_commit :broadcast_nomination
  after_update_commit :broadcast_nomination_replace

  private

  def broadcast_nomination
    broadcast_append_to "cycle_#{cycle_id}_nominations",
      partial: "nominations/nomination",
      locals: { nomination: self },
      target: "nominations_list"
  end

  def broadcast_nomination_replace
    broadcast_replace_to "cycle_#{cycle_id}_nominations",
      partial: "nominations/nomination",
      locals: { nomination: self },
      target: "nomination_#{id}"
  end
end
