class UserPresenter < ApplicationPresenter
  def initials
    name = user.name.to_s.strip
    return "?" if name.blank?

    name.split.first(2).map { |word| word[0]&.upcase }.join
  end

  def avatar_chip(tone)
    view_context.content_tag :span,
      initials,
      class: "nc-avatar-chip nc-avatar-chip--#{tone}",
      data: { name: user.name },
      aria_label: "Avatar for #{user.name}"
  end

  private

  def user
    record
  end
end
