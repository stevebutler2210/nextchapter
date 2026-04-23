# ADR-010 — Vote tally broadcasts dispatched from the controller; state-change broadcasts via model callback

Status: Accepted
Date: 2026-04-23

## Context

NextChapter uses Turbo Streams to push real-time updates to connected club
members. Three broadcast patterns are now in use across the codebase:

1. **Nomination broadcasts** — `after_create_commit` / `after_update_commit`
   model callbacks on `Nomination`
2. **Vote tally broadcasts** — `BroadcastVoteTallyJob` dispatched explicitly
   from `VotesController`
3. **Cycle state-change broadcasts** — `after_update` callback on `Cycle`,
   firing `Turbo::StreamsChannel.broadcast_refresh_to` when state changes

The asymmetry between patterns 1 and 2 requires explanation.

## Decision

**Nomination broadcasts use model callbacks.** The create-and-broadcast flow
is simple and synchronous; the callback fires reliably in this context.

**Vote tally broadcasts use an explicit job dispatched from the controller.**
`after_create_commit` on `Vote` was implemented first but proved unreliable:
the callback fired inside a `SolidCable::TrimJob` thread in the Solid
Cable/SQLite threading context and was silently swallowed. Moving the
broadcast to an explicit job dispatched from the controller resolved this.
The controller is the right place to own the side-effect in any case — the
broadcast is a consequence of the HTTP action, not an intrinsic property of
the Vote model.

**Cycle state-change broadcasts use a model callback** (`after_update` scoped
to `saved_change_to_state?`). This is a page-level `broadcast_refresh_to`
rather than a partial update, so it does not share the threading issue that
affected Vote. The Cycle model is the canonical owner of state, making it the
natural place for this side-effect.

## Alternatives considered

- **Model callback for vote tallies** — tried and rejected; silently failed
  in the Solid Cable/SQLite threading context.
- **Controller dispatch for all broadcasts** — consistent but would require
  moving nomination and cycle broadcasts out of models where they sit cleanly.
- **Single broadcast pattern for everything** — not pursued; the three use
  cases have meaningfully different characteristics (partial update vs page
  refresh, model-owned state vs controller-owned action).

## Consequences

- The asymmetry is intentional and documented here. Future broadcast work
  should default to model callbacks for model-owned state changes and
  controller dispatch for action-driven side-effects.
- The Solid Cable/SQLite threading issue may not affect other callback types
  — nominations are unaffected. The root cause is specific to the Vote
  create flow in that threading context.
- `BroadcastVoteTallyJob` is the established pattern for controller-dispatched
  broadcasts; new jobs of this type should follow the same structure.
