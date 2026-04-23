# ADR-009 — Presenter layer for view logic

Status: Accepted
Date: 2026-04-21

## Context

The voting UI requires per-nomination logic that depends on both the
nomination record and the current user: whether the user has voted, which
nomination they voted for, and whether the vote button should be disabled.
This logic needs to live somewhere.

Three options were considered:

- **Helpers** — stateless functions in a module; no natural home for
  per-object state like current_user context
- **Decorators via a gem (Draper)** — adds a dependency; the pattern it
  provides can be replicated with a small base class at this scope
- **Plain presenter objects** — a base class with `delegate_missing_to :record`
  provides transparent delegation to the underlying model; no gem required

## Decision

Introduce a presenter layer with an `ApplicationPresenter` base class.

`ApplicationPresenter` uses `delegate_missing_to :record` so presenters
are transparent wrappers — methods not defined on the presenter delegate
to the model automatically. Presenters live in `app/presenters/`.
Instantiated in views via `ApplicationHelper#present(record, current_user:)`.

`NominationPresenter` is the first concrete presenter, encapsulating vote
button logic and disabled state.

## Alternatives considered

- **Helpers** — rejected: stateless; awkward to pass `current_user` context
  through multiple helper calls without polluting the helper module with
  state.
- **Draper** — rejected: adds a gem dependency that the base class approach
  fully replaces at this scope. Draper would be a reasonable choice if the
  pattern grew significantly.
- **Logic in the view or partial** — rejected: tested logic in a presenter
  is preferable to untested conditionals in ERB.

## Consequences

- View logic with user context now has a consistent, testable home.
- `delegate_missing_to :record` means presenters are safe to pass to partials
  that expect the underlying model — no interface mismatch.
- The pattern is lightweight enough to extend without a gem; revisit Draper
  only if presenter count or complexity grows significantly.
- New per-object view logic with user context should follow this pattern
  rather than reaching for helpers or inline conditionals.
