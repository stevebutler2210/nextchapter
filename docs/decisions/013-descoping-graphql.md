# ADR-013: GraphQL descoped in favour of REST

**Date:** 2026-04-25
**Status:** Accepted

## Context

GraphQL (#52) was listed as a tier-2 stretch goal in the original plan—the
intent was to expose the same data as the REST API via a GraphQL endpoint
alongside it, with the mobile app optionally switching to GraphQL on Day 9.

The REST API (#47) shipped and covers all data the mobile app needs: auth,
clubs, current cycle, nominations, and book lookup. No mobile screen requires
a query shape that REST handles poorly. GraphQL was always conditional on the
REST API shipping first and time remaining—neither condition ended up
favouring it.

## Decision

Descope GraphQL entirely. The mobile app will use the REST endpoints for all
data fetching. The `#52` ticket will be closed as won't-do with a note
pointing to this ADR.

## Consequences

- No additional backend complexity. The REST controllers are the only API
  surface to maintain.
- If a future consumer (third-party integration, a more complex query
  requirement) makes GraphQL worthwhile, the decision can be revisited. The
  REST foundation does not preclude adding GraphQL later.
- The "tier-2 GraphQL" framing in PLAN.md should be noted as not shipped in
  the final JOURNAL retrospective.
