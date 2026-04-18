# ADR-001: Stack and Infrastructure

**Status:** Accepted

## Context
A 9-day solo project to build a working book club web app with a React Native
companion, used as a skills refresh exercise. Constraints: free-tier hosting
only, roughly 25–35 hours of focused time, two repositories.

The stack needed to be current enough to be credible to a hiring engineer
reviewing the project, while being stable enough not to waste days on
compatibility issues.

## Decision

**Ruby 3.4.9 and Rails 8.1.3**
The plan originally specified Ruby 3.3 and Rails 8.0. During day 1 setup, both
were updated: Rails 8.0.x moves to security-only support in May 2026, making it
a poor choice for a project started today. Ruby 4.0 was considered but rejected
on gem stability grounds. Ruby 3.4.9 is current stable and supported until
March 2028.

**SQLite for development and production**
Rails 8 ships with production-ready SQLite defaults (Solid Queue, Solid Cache,
persistent volumes on Fly.io). A book club app at this scale has no concurrency
requirements that would justify PostgreSQL. Keeps the stack simple and
free-tier hosting viable.

**Hotwire (Turbo + Stimulus) as the primary UI layer**
No client-side SPA. Hotwire gives a fast, modern UI without the complexity of
a separate frontend build. The React Native companion handles the one feature
the web can't do as well — ISBN barcode scanning.

**Fly.io for hosting**
Free tier, good Rails support, persistent volume support for SQLite. Deployed
on day 1 as an early smoke test — any infrastructure surprises surface early
rather than on day 7.

**Two-repo structure**
`nextchapter` (Rails monolith) and `nextchapter-mobile` (Expo/React Native).
Kept separate because the two apps have different toolchains, different
deployment targets, and different reviewers in mind. A monorepo would add
tooling complexity without meaningful benefit at this scale.

**`docs/decisions/` for ADRs**
The plan specified a single `DECISIONS.md`. After reading Nygard's original ADR
post, individual files in `docs/decisions/` were adopted instead. Each decision
gets its own commit history, and the format is recognisable to any engineer
familiar with the pattern. A single file would have made superseding individual
decisions awkward.

**Rails 8 built-in authentication generator**
Devise was explicitly ruled out. The built-in generator produces readable,
ownable code that is straightforward to extend. Registration flow was added
manually on top of the generated scaffold, as the generator intentionally omits
it. `reset_session` added on sign-in to mitigate session fixation. Password
minimum length set to 12 characters. Email uniqueness validated at the model
layer to surface a readable error rather than a database exception.

**`force_ssl` deferred**
Considered during authentication setup. Fly.io handles SSL termination, making
it redundant for this deployment target. Revisit on day 7 if the deployment
setup changes.

**Branch protection and merge strategy**
`main` is protected — all changes arrive via pull request. Squash merging
only, enforcing one commit per PR on `main`. Status checks (test, system-test,
lint, scan_ruby, scan_js) must pass before merge. Established on day 1 so the
working agreement is backed by repo config rather than relying on discipline
alone.


## Consequences
- Hotwire-first means the mobile app needs a separate API surface — planned for
  day 7.
- Two-repo structure requires keeping PLAN.md and WORKFLOW.md in sync manually.
- Owning the authentication code means owning any future extensions (OAuth,
  magic links, etc.).
