class NominationPresenter < ApplicationPresenter
  def vote_button
    if current_user.present? && voted_by?(current_user)
      view_context.button_to "Remove Vote",
        view_context.vote_path(votes.detect { |v| v.user_id == current_user.id }),
        method: :delete
    elsif current_user.present?
      view_context.button_to "Cast Vote",
        view_context.nomination_votes_path(nomination),
        method: :post,
        disabled: cycle.votes.exists?(user_id: current_user.id)
    end
  end

  private

  def nomination
    record
  end
end
