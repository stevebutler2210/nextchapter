# NextChapter — Workflow

How this project is built. Conventions, structure, and where to find things.

This document is shared between both repositories (`nextchapter` and
`nextchapter-mobile`) and is kept in sync.

---

## Repositories

- **`nextchapter`** — Rails 8 monolith. The web app, the API, and the primary
  source of truth.
- **`nextchapter-mobile`** — Expo / React Native companion app. Talks to the
  Rails API over JSON with JWT auth.

The two are tracked under a single GitHub Project board with one milestone
per day of work.

---

## Planning and decisions

Four docs carry the project's thinking. They are deliberately short — the full
set can be read in under fifteen minutes.

| Doc | What it's for | Where it lives |
|---|---|---|
| `docs/PLAN.md` | The day-0 plan. Committed at the start, not rewritten. | Both repos |
| `docs/DECISIONS.md` | Architecture Decision Records (Nygard format): one entry per meaningful choice, covering context, decision, and consequences. | `nextchapter` only |
| `docs/JOURNAL.md` | A short daily log. What shipped, what blocked, what changed from the plan. | `nextchapter` only |
| `docs/WORKFLOW.md` | This document. | Both repos |

The `nextchapter-mobile` README links to DECISIONS.md and JOURNAL.md in the
Rails repo. A single source of truth covers the whole project, including
decisions that span both sides (API shape, auth scheme).

PLAN.md is a historical artefact. Changes to scope, sequence, or approach are
recorded in JOURNAL.md rather than applied as edits to the plan. The gap
between plan and shipped is part of the project's story.

---

## Branching

- `main` is always deployable. No direct pushes.
- Every ticket gets its own branch off `main`.
- Branch names: `type/short-description` — e.g. `feat/club-invites`,
  `fix/book-lookup-rate-limit`, `docs/decisions-backfill`.
- Merge via PR with squash-and-merge. One PR per ticket, one commit per PR on
  `main`.

## Commits

Conventional Commits, with a lightweight scope rule.

### Types used

| Type | When |
|---|---|
| `feat` | A user-visible feature or behaviour change |
| `fix` | A bug fix |
| `refactor` | Internal change, no behaviour change |
| `test` | Adding or changing tests |
| `perf` | Performance-motivated change |
| `docs` | Docs only |
| `chore` | Tooling, dependencies, housekeeping |
| `ci` | CI config |
| `build` | Build system / dependencies |
| `style` | Formatting only, no code change |

### Scopes

Three scopes, applied to commits that ship behaviour (`feat`, `fix`,
`refactor`, `test`, `perf`):

- `backend` — changes to the Rails app
- `mobile` — changes to the Expo app
- `*` — cross-cutting change touching both sides or neither specifically

Commits where the type already carries the story (`docs`, `chore`, `ci`,
`build`, `style`) omit the scope.

### Examples

```
feat(backend): add Club and Membership models
feat(mobile): persist auth state with Expo SecureStore
fix(backend): handle Google Books rate-limit responses
refactor(backend): extract BookLookupService from controller
docs: add ADR-004 on REST vs GraphQL for mobile
chore: bump expo to SDK 52
ci: add lint step to PR workflow
```

### Breaking changes

Unlikely on a project this size, but if one arises: add a `BREAKING CHANGE:`
footer to the commit message explaining the break and the migration path.

---

## Tickets

Every unit of work is a GitHub issue. Issues use one of two templates.

### Feature template

```markdown
## Context
One or two sentences. What is this and why does it exist?
Link to any DECISIONS.md entry if one applies.

## Acceptance criteria
- [ ] Behaviour 1 (user-visible where possible)
- [ ] Behaviour 2
- [ ] Behaviour 3

## Notes
Anything worth capturing but not a hard requirement — guide links to read
first, open questions, things to verify.

## Out of scope
What this ticket explicitly does not cover.
```

### Spike / learning template

For reading docs before implementing something new.

```markdown
## Goal
What do I need to understand before I can implement X?

## Source(s)
- Guide link 1
- Guide link 2

## Outcome
A short note in DECISIONS.md or a comment on the related feature ticket,
capturing what I learned and any implementation implications.
```

### Labels

| Label | Purpose |
|---|---|
| `tier-1-core` | Must ship for the project to be credible |
| `tier-2-polish` | Nice-to-have (monitoring, additional API surfaces, deploy hardening) |
| `tier-3-stretch` | Beyond the committed scope — only if genuinely ahead |
| `backend` | Lives in the Rails repo |
| `mobile` | Lives in the mobile repo |
| `modern-rails` | Touches a Rails feature new to the author; read the guide first |
| `spike` | A learning ticket, not a feature |
| `decision` | Has a corresponding DECISIONS.md entry |

### Milestones

One milestone per day of work (`Day 1 — Foundations`, etc.), matching the
sections in PLAN.md. Every ticket is assigned to a milestone. The milestone
view gives a second timeline alongside PLAN.md — they should agree; where
they don't, JOURNAL.md explains why.

### When tickets are written

Tickets exist in two resolutions:

- **Stubs** — title and one-line description, created on day 0 for the whole
  project. Gives the GitHub Project board its full shape from the start.
- **Full tickets** — acceptance criteria, notes, out-of-scope. Expanded from
  stubs the morning of the day the work begins. Also where new tickets get
  added if the previous day surfaced something.

Full tickets for later days are not written in advance. Detail written on day 1
for day 9's work will be wrong by the time it's needed.

---

## Pull requests

- One PR per ticket. Title matches the ticket — `feat(backend): add Club and
  Membership models`.
- PR description includes `Closes #N` so the ticket auto-closes on merge.
- PR description is 2–3 lines: what this does, any trade-off worth noting.
- CI must pass before merge.
- Squash-and-merge. The commit message on `main` becomes the PR title.

---

## Testing

- **Backend**: Minitest. System tests for the core flows (club creation,
  nomination, voting). Unit tests for services (`BookLookupService`) and
  non-trivial models. Not aiming for full coverage — aiming for coverage where
  failure would hurt.
- **Mobile**: light. A single Maestro E2E flow is a tier-3 stretch goal. No
  unit testing framework beyond what Expo ships with.
- CI runs tests on every PR. A red CI blocks merge.

---

## Deployment

- **Rails app**: Fly.io, SQLite with a persistent volume. Deploys are triggered
  manually via `fly deploy` from `main`. No automatic production deploy on
  merge — a solo project does not require an automated gate.
- **Mobile app**: Expo EAS preview builds, shareable via link. No store
  submission.

---

## Running locally

See each repo's README for stack-specific setup. At a minimum:

- **`nextchapter`**: Ruby 3.3, Rails 8, `bin/setup` to install dependencies,
  create the database, and run seeds. `bin/dev` to start.
- **`nextchapter-mobile`**: Node 20, `npm install`, `npx expo start`.

---

## On AI assistance

This project was built with AI assistance — Claude for planning, scoping, and
decision rubber-ducking; Copilot for day-to-day code suggestions. The thinking
was collaborative; the judgment is the author's.

Every decision captured in DECISIONS.md is one the author understands, agreed
with after weighing alternatives, and can speak to under questioning. The
commit and PR history, together with DECISIONS.md and JOURNAL.md, show how the
project was built and why.
