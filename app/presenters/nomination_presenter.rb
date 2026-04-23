class NominationPresenter < ApplicationPresenter
  def vote_button
    return unless current_user.present?

    if voted_by?(current_user)
      user_vote = votes.find { |vote| vote.user_id == current_user.id }

      view_context.button_to "Remove Vote",
        view_context.vote_path(user_vote),
        method: :delete,
        class: "nc-button nc-button--voted"
    else
      view_context.button_to "Cast Vote",
        view_context.nomination_votes_path(nomination),
        method: :post,
        disabled: cycle.votes.exists?(user_id: current_user.id),
        class: "nc-button nc-button--primary"
    end
  end

  private

  def nomination
    record
  end
end
