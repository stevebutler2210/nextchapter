## Day 0 — Planning

Created both repositories. Committed PLAN.md and WORKFLOW.md to
`nextchapter-mobile/docs/`. Set up a public GitHub Project board with both
repos linked. Added labels, milestones, and issue templates to
`nextchapter-mobile`. Filed the mobile ticket stubs (11 issues).

Backend ticket stubs were not filed—deferred to Day 1 morning. No code
shipped.

## Day 1 — Foundations

**Shipped**

- Rails 8.1.3 / Ruby 3.4.9 app initialised—upgraded from the plan's 3.3 /
  8.0 targets. Rails 8.0.x moves to security-only support in May 2026; 8.1.3
  is current stable. Ruby 3.4.9 preferred over 4.0 on gem stability grounds.
  (ADR-001)
- `rails new` run with `--ci=github` to get a working Actions scaffold from
  the start; `--css` omitted
- Empty `test/system` directory with keepfile added to ensure CI system-test
  step passes without a rewrite later
- GitHub Actions CI green: test, system-test, lint, scan_ruby, scan_js all
  passing on PR
- Authentication via Rails 8 generator, with the following additions:
  - 12-character password minimum (no complexity rules)
  - `reset_session` on sign-in to mitigate session fixation
  - Email uniqueness validated at model layer
  - `created_at` on the Sessions table—commented as a day 7 hardening
    reminder for future session expiry sweeps
  - `force_ssl` considered and deferred—Fly.io handles SSL termination
- Club and Membership models with migrations (ADR-002)
- Seed script: sample club, two users, a cycle mid-voting, book data
- ADR-001 (stack and infrastructure) and ADR-002 (initial data model)
  committed to `docs/decisions/`—individual files rather than a single
  DECISIONS.md, following Nygard's original format
- Test fixtures kept over Factory Bot—appropriate for this scope
- Skeleton deployed to nextchapter.fly.dev. Two Dockerfile issues surfaced
  and fixed: `/rails` chown scope too narrow; Thruster removed in favour of
  Rails serving directly on port 8080 (non-root user can't bind to port 80)
- Branch protection and squash-merge enforced on main

**Deferred**

- Backend ticket stubs for days 2–9 not filed—carrying forward to Day 2
  morning
- JOURNAL Day 1 entry written the following morning

**Surprises / deviations**

- Ruby and Rails versions both bumped from plan (see above)—no downstream
  impact on day 1 scope
- Two Fly.io deployment issues added some time; both resolved and documented
  in ADR-001
- Root route is a temporary placeholder (`sessions#new`) rather than an
  authenticated dashboard—intentional day 1 shortcut

**Open questions into Day 2**

- Credentials setup deferred to Day 7—ticket notes to be updated when
  filing stubs today
- `force_ssl` revisit flagged for Day 7 depending on deployment setup

## Day 2 — Clubs and membership

**Shipped**

- Backfilled JOURNAL entries for Days 0 and 1
- Full tickets written for Day 2; stubs filed for Days 3–9 including
  a Day 9 TODO sweep ticket
- Extra ticket added: skip CI on docs-only PRs (`paths-ignore` fix)
- Authenticated dashboard replacing the temporary root route placeholder
  from Day 1; sign-out link added to layout
- Club CRUD: scoped index, create with transaction, show, edit, update,
  destroy. Owner-only enforcement via `before_action`. Turbo Frame for
  the new club form (loads in-place, updates list on success). Edit form
  loads in-place on the detail page via a named frame.
- Signed invite links via `signed_id(expires_in: 1.week)`. Separate
  `InvitesController` handling valid, expired/invalid, already-a-member,
  and unauthenticated scenarios. `request_authentication` overridden for
  contextual flash. `return_to` preserved across `reset_session`.
- First Stimulus controller: clipboard copy button on club detail page.
  Reads URL from a `source` target span, updates button text to "Copied!"
  for 2 seconds on success.
- ERB excluded from Prettier via `.vscode/settings.json`
  after formatter was mangling indentation on save
- Request tests for `ClubsController` and `InvitesController`. All
  passing.

**Deferred**

- Stimulus controller system test deferred to Day 6 polish/test pass—
  noted on that ticket

**Surprises / deviations**

- Prettier/ERB formatter conflict consumed ~45 minutes. Root cause: the
  `bung87.rails` VS Code extension was formatting ERB on save independently
  of Prettier. Resolved by disabling format-on-save for ERB in
  `.vscode/settings.json`.
- `return_to` was being wiped by `reset_session` on sign-in—required a
  stash-and-restore pattern in `SessionsController` to preserve post-login
  redirect for invite links.
- Day 2 completed ~30 minutes inside the planned window despite the
  formatter issues.

**Planning note**

Reviewed remaining day scoping against actual pace. Days 3 and 4 are
the best pull-ahead opportunities. Day 8 (mobile auth + JWT plumbing)
is the highest-risk day. Decision: pull Day 3 forward to this evening
as a focused session to bank time before the week's 3-hour day blocks.
Total hours ceiling revised to ~40 to preserve the "delivered in a
working week" narrative without compromising on quality.

**Open questions into Day 3**

- Turbo Streams spike needed before live book search implementation
- Solid Queue guide needed before cover image caching job
- Google Books API key setup required—confirm credentials approach
  before starting `BookLookupService`
