# ADR-009 — Tie-break: random selection among tied nominations

Status: Accepted
Date: 2026-04-22

## Context

When voting closes, `Cycle#close_voting_and_select_winner!` must declare a
winner. If two or more nominations share the highest vote count, a tie-break
rule is needed.

Two options were considered:

- **Earliest nomination wins** — deterministic; rewards members who nominated
  early; original planned approach
- **Random selection** — non-deterministic per run; treats all tied
  nominations equally regardless of when they were submitted

## Decision

Use random selection (`Array#sample`) among tied nominations.

Earliest-nomination-wins was the original plan but was reconsidered before
implementation. Rewarding early nomination creates a mild incentive to
nominate quickly rather than thoughtfully, which cuts against the app's
character. Random selection is simpler to reason about and treats a tie as
what it is: the group genuinely couldn't decide.

The return value of `close_voting_and_select_winner!` signals whether the
outcome was `:tied` or `:clear_winner`, giving the controller the option to
surface this to users if needed.

## Alternatives considered

- **Earliest nomination wins** — rejected: deterministic but creates a
  perverse incentive; inconsistent with the app's intent.
- **Club owner breaks the tie manually** — rejected: adds UI and state
  complexity not justified at this scope; defers a decision the system can
  make cleanly.

## Consequences

- Tie outcomes are non-deterministic — the same tied vote will not always
  produce the same winner. This is intentional.
- `close_voting_and_select_winner!` returns `:tied` or `:clear_winner` —
  callers can use this to show a "it was a tie!" message if desired.
  Not yet surfaced in the UI; available when needed.
- `Array#sample` uses Ruby's default PRNG — not cryptographically random,
  which is appropriate for this use case.
