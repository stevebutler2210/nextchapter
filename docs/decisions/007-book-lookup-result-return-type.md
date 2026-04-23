# ADR-007 — BookLookupService::Result as a Data class rather than Struct

Status: Accepted
Date: 2026-04-20

## Context

`BookLookupService` needs a return type for search results and ISBN lookups.
The return type is used in both the web search results partial and the mobile
barcode scan flow, so it needs to be consistent and safe to pass around.

Two built-in Ruby options were considered:

- **`Struct`** — familiar, lightweight, but mutable by default and uses
  positional arguments unless keyword_init is set explicitly
- **`Data`** — introduced in Ruby 3.2, immutable by design, keyword arguments
  only, value-equality semantics

## Decision

Use `Data` for `BookLookupService::Result`.

`Data` is immutable, which is appropriate for a read-only value object
representing an external API response. Keyword arguments reduce the risk of
positional argument errors when the result shape changes. `Struct` offered no
advantage at this scope.

The class is defined as a nested constant (`BookLookupService::Result`) to
keep it co-located with the service that produces it.

Connection is injected via keyword argument on the service itself for
testability without monkey-patching.

## Alternatives considered

- **`Struct`** — rejected: mutable by default; no meaningful advantage over
  `Data` for a read-only result type.
- **Dedicated plain Ruby class** — would add boilerplate (`attr_reader`,
  `initialize`, `==`) without benefit at this scope.
- **Hash** — rejected: no type boundary, no defined shape, harder to test
  against.

## Consequences

- `BookLookupService::Result` is immutable — callers cannot modify returned
  results, which is the correct behaviour for an API cache.
- The `cover_image_url` method is defined on both `Result` and `Book` with
  the same interface, so the `_results` partial works with both types without
  type-checking.
- Ruby 3.2+ required — already satisfied by the Ruby 3.4.9 pin in ADR-001.
