# ADR-002: Initial Data Model

**Status:** Accepted

## Context
The app's core loop is: form a club, nominate books, vote on what to read next,
track reading, move to the next cycle. The data model needs to support this loop
end to end while staying simple enough to build in 9 days.

## Decision

**Entities and relationships**

- **User** — email address and password digest. Created by the Rails 8 auth
  generator.
- **Club** — has a name, description, and a creating User. The top-level
  grouping for all activity.
- **Membership** — joins User to Club with a role (owner, member). A User can
  belong to many Clubs; a Club has many Users through Membership. Only the
  club owner may advance a Cycle through its states — this constraint is
  enforced at the controller layer.
- **Book** — title, authors, ISBN, external_id (Google Books), cover_url. Books
  are looked up via the Google Books API and cached locally. Not owned by a
  Club — the same book can be nominated across multiple clubs and cycles.
- **Cycle** — belongs to a Club. Represents one round of nominating, voting,
  and reading. Has a state machine: nominating → voting → reading → complete.
- **Nomination** — joins Book, Cycle, and User. A User nominates a Book into a
  Cycle. One nomination per user per cycle, enforced by a unique index.
- **Vote** — joins User and Nomination within a Cycle. One vote per user per
  cycle, enforced by a unique index. First-past-the-post counting only.
- **ReadingLogEntry** — joins User and Cycle. Records a member's reading
  progress on the winning book (started, progressing, finished). Includes a
  private notes field encrypted with Active Record Encryption.

**Key field decisions**
- `Sessions.created_at` — included via `t.timestamps` to enable future
  time-based session expiry sweeps. A comment in the model flags this for day 7
  hardening.
- Book is kept as a first-class model rather than embedding data in Nomination,
  to allow reuse across clubs and cycles without duplication.
- Cycle state is a string enum — readable in the database and straightforward
  to extend.

## Consequences
- The Cycle state machine needs careful handling — invalid transitions should
  raise rather than silently fail.
- Active Record Encryption on ReadingLogEntry notes requires
  `RAILS_MASTER_KEY` to be correctly set in production. Flagged for day 7.
- Nomination and Vote uniqueness constraints need database-level unique indexes,
  not just model validations.
- Only owners can advance Cycles — the membership role check must be applied
  consistently across any controller action that changes Cycle state.
