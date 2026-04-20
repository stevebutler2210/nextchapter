# ADR-005 — Minitest version pin

Status: Accepted
Date: 2026-04-19

## Context

Minitest 6 removes mock and stub support into a standalone gem
(`minitest-mock`) that was not stable at the time of this decision.
NextChapter uses mocks and stubs in service object tests.

## Decision

Pin Minitest to `~> 5.25` in the Gemfile.

## Alternatives considered

- **Minitest 6 + minitest-mock** — would require adopting an unstable
  standalone gem. Risk not justified while the gem is pre-stable.
- **RSpec** — not a meaningful alternative here; replacing the test framework
  mid-project to work around a version constraint would be disproportionate.

## Consequences

- Mocks and stubs work as expected with no additional dependencies.
- Pin should be revisited when `minitest-mock` reaches a stable release.
