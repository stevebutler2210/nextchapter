## Day 0 — Planning

Created both repositories. Committed PLAN.md and WORKFLOW.md to
`nextchapter-mobile/docs/`. Set up a public GitHub Project board with both
repos linked. Added labels, milestones, and issue templates to
`nextchapter-mobile`. Filed the mobile ticket stubs (~7 issues).

Backend ticket stubs were not filed—deferred to Day 1 morning. No code
shipped.

## Day 1 — Foundations

**Shipped**
- Rails 8.1.3 / Ruby 3.4.2 app initialised—upgraded from the plan's 3.3 /
  8.0 targets. Rails 8.0.x moves to security-only support in May 2026; 8.1.3
  is current stable. Ruby 3.4.2 preferred over 4.0 on gem stability grounds.
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
