# NextChapter — Plan

A small web-and-mobile book club app. Groups of readers form a club, nominate
books, vote on what to read next, and track what they've read together.

This document is the plan as it stood at the start of the project. It is
committed on day 0 and not rewritten. Changes to scope, sequence, or approach
are captured in `JOURNAL.md` so the plan-as-shipped can be diffed against the
plan-as-drafted.

---

## Goals

- A working book club app with the core loop: form a club, nominate a book,
  vote, settle on a winner, track reading, move to the next cycle.
- Rails 8 monolith with Hotwire as the primary UI — no client-side SPA.
- A small React Native companion that adds one feature the web can't do as well:
  ISBN barcode scanning to add a book.
- Deployed and demoable on free infrastructure.

## Non-goals

- Feature parity between web and mobile.
- Social features beyond a single club (no following users, no public feeds, no
  discovery across clubs).
- Reading analytics, statistics, or recommendations.
- Integration with external reading platforms (Goodreads, StoryGraph, Kindle).
- Offline-first behaviour on mobile.
- Multi-tenancy, billing, or any admin tooling beyond what a single user needs.

## Constraints

- Roughly 25–35 hours of focused time across 9 days.
- Free-tier hosting only.
- Two repositories: `nextchapter` (Rails) and `nextchapter-mobile` (Expo/RN).
- Built solo.

## How this plan is used

The plan is the day-0 expected shape of the work. Adjustments are expected in
both directions.

**Trimming.** If a day or the project as a whole runs short of time, work is
cut in reverse tier order — tier 3 first, then tier 2, preserving tier 1.
Whole days can also be dropped (tier 3's Loom walkthrough or Maestro flow are
the natural candidates). Each cut is noted briefly in JOURNAL.md with the
reason.

**Pulling forward.** If a day finishes ahead of schedule, the next day's
tier 1 work is pulled in first, then tier 2, then tier 3. Spare time is not
used to invent new scope — it goes into polish, tests, or documentation on
work already in flight.

**The plan itself is not rewritten.** Once this document is committed on day 0,
it stays as it was. The gap between plan-as-drafted and plan-as-shipped is
captured in JOURNAL.md, which lets a reviewer see both the initial thinking
and how it evolved under real constraints.

---

## Definition of done

The project is considered shipped when:

- A visitor can sign up, create a club, invite others (by share link), nominate
  a book, vote in a cycle, see a winner declared, and log that they've read it.
- All core flows work on the deployed URL without errors.
- The mobile app can authenticate against the deployed API and add a book by
  ISBN scan.
- The README gives a reviewer everything they need to understand and run the
  project in under ten minutes.
- `PLAN.md`, `DECISIONS.md`, `JOURNAL.md`, and `WORKFLOW.md` are all present and
  consistent with the shipped code.

---

## Tech stack

### `nextchapter` — Rails monolith

- Ruby 3.3, Rails 8.0
- SQLite for development and production, leaning on Rails 8's production-ready
  SQLite defaults
- Hotwire (Turbo + Stimulus) for the UI
- Propshaft + import maps for assets
- Solid Queue for background jobs
- Solid Cache for caching
- Active Storage for book covers
- Active Record Encryption for private reading notes
- Rails 8 built-in authentication generator (not Devise)
- Faraday for external API calls to Google Books
- Minitest for tests
- Deployed to Fly.io

### `nextchapter-mobile` — Expo / React Native

- Expo SDK (latest), React Native, TypeScript
- Expo Router for navigation
- `expo-camera` or `expo-barcode-scanner` for ISBN scanning
- JWT auth against the Rails API
- Distributed via Expo EAS (shareable preview builds)

### Cross-cutting

- GitHub Actions for CI (lint + test on PR)
- Conventional Commits with `backend`, `mobile`, and `*` scopes
- One GitHub Project spanning both repos, one milestone per day

---

## Tiers

Every ticket is assigned a tier. If time runs short, tier 3 goes first, then
tier 2, preserving tier 1 as the minimum credible shipped product.

- **Tier 1 — core.** Everything needed for the definition of done above.
- **Tier 2 — polish.** GraphQL API alongside REST for the mobile client,
  Sentry on both sides, production hardening, deploy documentation.
- **Tier 3 — stretch.** Maestro E2E flow, push notifications for club activity,
  anything else only reached if the project is genuinely ahead of schedule.

---

## Day-by-day

Each day links to its milestone on the GitHub Project. Modern-Rails features
new to the author are flagged with **[read guide first]** — these are the
slow-down moments where the relevant Rails guide section is read before any
code is written.

### Day 1 — Foundations

**Goal**: a running Rails 8 app with authentication, a deployed skeleton, the
data model outline committed, and a seed script for local development.

- Create the `nextchapter` repo from `rails new` with the Rails 8 defaults
- Commit the WORKFLOW.md, PLAN.md, and an empty JOURNAL.md / DECISIONS.md
- Set up GitHub Actions for a basic test + lint run on PR
- Generate authentication using the Rails 8 auth generator **[read guide first]**
- Sketch the data model (User, Club, Membership, Cycle, Nomination, Vote, Book,
  ReadingLogEntry) as a migration plan in DECISIONS.md
- Create the initial Club and Membership models with migrations
- Write `db/seeds.rb` with a sample club, a couple of users, a cycle mid-voting,
  and some book data for quick local setup
- Deploy an empty authenticated-home-page skeleton to Fly.io

**End of day**: a deployed URL where you can sign up, log in, and see an empty
dashboard. No clubs yet.

### Day 2 — Clubs and membership

**Goal**: users can create clubs and invite others.

- Club CRUD (name, description, created_by)
- Membership model with roles (owner, member)
- Shareable invite links (signed, expiring) **[read guide first — `signed_id`]**
- Turbo-powered club list and club detail pages
- First Stimulus controller (e.g. copy-invite-link button) **[read guide first]**

**End of day**: two test users can share a club via invite link.

### Day 3 — Books and external lookup

**Goal**: books exist in the system and can be fetched from Google Books.

- Book model (title, authors, isbn, external_id, cover_url)
- `BookLookupService` wrapping Faraday calls to Google Books
- Search-as-you-type book lookup on the web using Turbo Streams
  **[read guide first]**
- Active Storage attachment for local book cover caching
- Background job to cache cover images via Solid Queue **[read guide first]**

**End of day**: typing in a search box returns book results live without a
page reload.

### Day 4 — Cycles and nominations

**Goal**: clubs run reading cycles; members nominate books.

- Cycle model with states: `nominating`, `voting`, `reading`, `complete`
- State transitions exposed via dedicated controller actions (no full state
  machine gem — plain Active Record with validation)
- Nomination model linking a Book to a Cycle with a nominating User
- Nomination UI: search a book → nominate → see current nominations for the
  cycle
- Turbo Stream broadcast of new nominations to all club members viewing the
  cycle page **[read guide first]**

**End of day**: a club owner can start a nomination cycle; members can nominate
books; new nominations appear live on other members' screens.

### Day 5 — Voting and winners

**Goal**: members vote; a winner is declared; the cycle moves to reading.

- Vote model (one vote per user per cycle; simple first-past-the-post)
- Voting UI with real-time tally via Turbo Streams
- "Close voting" action on the cycle that locks votes and declares a winner
- "Start reading" transition that moves the cycle to `reading` state
- ReadingLogEntry model — members can mark the winning book as started,
  progressed, finished
- Private reading notes field on ReadingLogEntry using Active Record Encryption
  **[read guide first]**

**End of day**: a full cycle can run end to end — nominate, vote, close,
declare winner, members log their progress.

### Day 6 — Polish, testing, and rough edges

**Goal**: the core loop is robust and legible.

- Cover the core flows with system tests (club creation, nomination, voting)
- Fix styling — Tailwind or plain CSS, but consistent and readable
- Empty states for every list view (no clubs yet, no nominations yet, etc.)
- Error states for the Google Books lookup (rate limited, no results, network
  error)
- Flash messages that don't look like the default Rails flash
- A simple landing page at `/` for logged-out visitors explaining the app

**End of day**: the deployed app is something you'd be comfortable demoing on a
call without caveats.

### Day 7 — API surface, deploy hardening, and docs

**Goal**: the project is legible to a reviewer landing on the repo cold, and
the API surface the mobile app needs is in place.

- Expose JSON API endpoints the mobile app will consume on day 8: JWT sign-in,
  current user's clubs, a club's current cycle and its nominations, and the
  book-lookup endpoint. REST, plain Rails controllers, scoped only to what the
  mobile app actually needs.
- Production readiness: custom 500/404 pages, Rails credentials set up, correct
  timezone and locale defaults
- README polish: what it is, how to run it, link to deployed demo, screenshots
  or GIF, tech stack summary, links to the other docs
- DECISIONS.md backfilled so every meaningful choice made in days 1–6 has an
  entry (there should be roughly 8–12 by end of day)
- JOURNAL.md reviewed — should have one short entry per day
- **Tier 2 start**: Sentry wired up on the Rails side, minimal error reporting
  smoke-tested
- **Tier 2**: expose the same data via a GraphQL endpoint alongside REST. The
  mobile app can optionally switch to GraphQL on day 9 if this ships; otherwise
  it stays on the REST endpoints above with no downstream impact.

**End of day**: a reviewer opening the repo can understand the project in ten
minutes and run it locally. The mobile app has a stable API to build against.

### Day 8 — Mobile companion, part 1

**Goal**: a working mobile app that authenticates and lists clubs.

- Create `nextchapter-mobile` repo with Expo + TypeScript
- Port WORKFLOW.md; create a mobile-specific README
- Auth screens: sign in / sign up hitting the Rails API with JWT
- Persistent auth state using Expo SecureStore
- Tab navigation via Expo Router: Clubs, Scan, Profile
- Clubs tab: list the current user's clubs, tap through to club detail
- Club detail: show current cycle and its nominations

**End of day**: mobile app runs on an Expo preview build, signed in as a real
user, showing real club data from the deployed API.

### Day 9 — Mobile companion, part 2 and wrap

**Goal**: the mobile-only feature ships, everything is documented, and the
project is release-ready.

- ISBN barcode scan screen using `expo-barcode-scanner`
- On scan: call Rails `BookLookupService` with the ISBN, show the result, allow
  the user to nominate the book to a chosen club's current cycle
- Loading and error states for scan → lookup → nominate
- Expo EAS preview build published, link added to the mobile README
- Final pass on both READMEs, cross-linking, demo URLs, screenshots
- Final DECISIONS.md pass — all decisions through day 9 captured
- Final JOURNAL.md entry — retrospective on the plan-vs-shipped diff
- **Tier 3, if time remains**: a single Maestro flow (sign in → scan → nominate)
- **Tier 3, if time remains**: a short Loom walkthrough of the deployed app

**End of day**: project is shipped, documented, and linkable.

---

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| Google Books API rate limiting during development | Cache responses aggressively via Solid Cache; fall back to Open Library if rate limits bite |
| Turbo Stream broadcast setup takes longer than expected | Day 4 has the most unfamiliar modern-Rails surface — if it overruns, push voting (day 5) live-tallying to polling as a fallback |
| Fly.io free tier quirks with SQLite and persistent volumes | Deploy a skeleton on day 1 so any infra surprises surface early, not on day 7 |
| Mobile auth plumbing with JWT eats day 8 | If auth isn't solid by mid-day 8, cut the clubs-list feature and go straight to a minimal "logged-in, can scan" demo |
| Scope creep on voting rules (ranked choice, quadratic, etc.) | Explicitly first-past-the-post in scope; anything else is out of scope |
| Writing detailed tickets for days 6–9 on day 0 wastes effort that gets rewritten | Tickets are stubs only until the morning they're worked on |

---

## Ticket stubs

These are committed as GitHub issues on day 0 in stub form (title + one line).
Acceptance criteria are added the morning each day's work begins.

All tickets live in the `nextchapter` repo unless marked `[mobile]`, in which
case they live in `nextchapter-mobile`.

### Day 1 — Foundations
- `feat(backend): initialise Rails 8 app with default stack` — tier 1
- `chore(*): add PLAN, WORKFLOW, JOURNAL, DECISIONS docs` — tier 1
- `ci(*): add GitHub Actions for lint and test on PR` — tier 1
- `feat(backend): add authentication via Rails 8 generator` — tier 1, modern-rails
- `feat(backend): add Club and Membership models` — tier 1
- `feat(backend): seed script for local dev (sample club, users, cycle, books)` — tier 1
- `chore(backend): deploy skeleton to Fly.io` — tier 1

### Day 2 — Clubs and membership
- `feat(backend): club CRUD with Turbo-powered list and detail views` — tier 1
- `feat(backend): membership roles (owner, member)` — tier 1
- `feat(backend): signed invite links for joining a club` — tier 1, modern-rails
- `feat(backend): Stimulus controller for copy-invite-link button` — tier 1, modern-rails

### Day 3 — Books and external lookup
- `feat(backend): Book model with Google Books fields` — tier 1
- `feat(backend): BookLookupService wrapping Google Books via Faraday` — tier 1
- `feat(backend): live search-as-you-type book lookup via Turbo Streams` — tier 1, modern-rails
- `feat(backend): Active Storage attachment for book covers` — tier 1
- `feat(backend): Solid Queue job to cache cover images` — tier 1, modern-rails

### Day 4 — Cycles and nominations
- `feat(backend): Cycle model with state transitions` — tier 1
- `feat(backend): Nomination model linking Book, Cycle, User` — tier 1
- `feat(backend): nomination UI — search and add to current cycle` — tier 1
- `feat(backend): Turbo Stream broadcast nominations to club members` — tier 1, modern-rails

### Day 5 — Voting and winners
- `feat(backend): Vote model, one-per-user-per-cycle` — tier 1
- `feat(backend): voting UI with live tally via Turbo Streams` — tier 1
- `feat(backend): close-voting action that declares a winner` — tier 1
- `feat(backend): cycle transition to reading state` — tier 1
- `feat(backend): ReadingLogEntry with start / progress / finish states` — tier 1
- `feat(backend): Active Record Encryption on private reading notes` — tier 1, modern-rails

### Day 6 — Polish, testing, and rough edges
- `test(backend): system tests for club creation, nomination, voting` — tier 1
- `feat(backend): styling pass across all core flows` — tier 1
- `feat(backend): empty states for all list views` — tier 1
- `feat(backend): error states for external book lookup` — tier 1
- `feat(backend): landing page for logged-out visitors` — tier 1

### Day 7 — API surface, deploy hardening, and docs
- `feat(backend): expose JSON API endpoints for mobile client (auth, clubs, cycles, nominations, book lookup)` — tier 1
- `feat(backend): custom 404 / 500 pages, production polish` — tier 1
- `docs(*): README polish with demo link, screenshots, stack summary` — tier 1
- `docs(*): backfill DECISIONS entries for days 1–6` — tier 1
- `feat(backend): wire up Sentry error reporting` — tier 2
- `feat(backend): expose same data via GraphQL endpoint alongside REST` — tier 2

### Day 8 — Mobile companion, part 1
- `chore(mobile): scaffold Expo + TypeScript project [mobile]` — tier 1
- `docs(mobile): mobile README and workflow docs [mobile]` — tier 1
- `feat(mobile): sign in and sign up screens hitting Rails JSON API with JWT [mobile]` — tier 1
- `feat(mobile): persist auth state with Expo SecureStore [mobile]` — tier 1
- `feat(mobile): tab navigation via Expo Router [mobile]` — tier 1
- `feat(mobile): clubs tab listing user's clubs [mobile]` — tier 1
- `feat(mobile): club detail showing current cycle and nominations [mobile]` — tier 1

### Day 9 — Mobile companion, part 2 and wrap
- `feat(mobile): ISBN barcode scan screen [mobile]` — tier 1
- `feat(mobile): scan-to-nominate flow [mobile]` — tier 1
- `chore(mobile): publish Expo EAS preview build [mobile]` — tier 1
- `docs(*): final README pass, cross-linking, demo URLs` — tier 1
- `docs(*): final DECISIONS and JOURNAL pass` — tier 1
- `test(mobile): Maestro E2E flow for sign in → scan → nominate [mobile]` — tier 3
- `docs(*): Loom walkthrough of deployed app` — tier 3
