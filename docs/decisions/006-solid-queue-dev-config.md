# ADR-006 — Solid Queue development configuration

Status: Accepted
Date: 2026-04-20

## Context

Solid Queue is used for background jobs (introduced in Day 3 for
CacheCoverImageJob). In development, Solid Queue requires a separate queue
database to mirror the multi-database production configuration. A process
manager is also needed to run the web server and queue worker concurrently.

## Decision

Configure a dedicated queue database for development. Replace the bare
`rails server` wrapper in `bin/dev` with a Foreman setup running web and
worker processes together.

## Relationship to ADR-001

ADR-001 recorded the decision to use Solid Queue. This ADR records the
consequential implementation detail of how it is configured in development,
which was not known at the time ADR-001 was written. ADR-001 is left
unchanged.

## Alternatives considered

- **Single database for development** — not viable; Solid Queue's schema
  requires a separate database to function correctly in a multi-database setup.
- **Running worker manually** — workable but fragile; easy to forget,
  leading to jobs silently not processing during development.

## Consequences

- `bin/dev` now starts both processes; development environment matches
  production more closely.
- Foreman added as a dependency.
- Bare `rails server` no longer sufficient to run the full application locally.
