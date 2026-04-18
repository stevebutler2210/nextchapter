class Session < ApplicationRecord
  belongs_to :user

  # created_at (via t.timestamps) enables time-based session expiry sweeps.
  # TODO: implement sweep to clear sessions older than X days - day 7 hardening issue.
end
