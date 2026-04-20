# ADR-003 — Google Books as the external book search API

Status: Accepted

## Context

NextChapter needs a way to search for books by title or author and retrieve
structured metadata: title, authors, ISBN, cover image, publisher, and
publication date. The alternative to an external API is manual entry, which
is a poor user experience for a book club app and out of scope for this
project.

Three external options were considered:

- **Google Books API** — free tier (1,000 requests/day), comprehensive
  metadata, thumbnail cover images, ISBN lookup support, well-documented JSON
  API, requires an API key
- **Open Library (Internet Archive)** — fully open, no API key required,
  coverage and metadata quality are inconsistent, cover images less reliable
- **ISBNdb** — good ISBN coverage, requires a paid subscription for meaningful
  request volumes

## Decision

Use the Google Books API.

The free tier is sufficient for a demo-scale app. Metadata quality and cover
image availability are meaningfully better than Open Library for mainstream
titles. ISBN lookup is a first-class feature, which is needed for the mobile
barcode scan flow on Day 9. No cost at this scale.

The 1,000 requests/day quota is a real constraint. Mitigated by: debouncing
the search input in the UI (~300ms), caching cover images locally via Active
Storage after first fetch, and using Open Library as a documented fallback if
the quota becomes a problem during development.

The API key is stored in Rails credentials (`google_books_api_key`), not in
ENV or source control.

## Consequences

- A Google account and API key are required to run the app with live search.
  The README will document this as a setup step.
- The 1,000 request/day free tier limit requires defensive use in both
  development and production.
- `BookLookupService` wraps all Google Books calls, so switching to Open
  Library as a fallback is isolated to one class.
- `google_books_id` is used as the stable external identifier on the `Book`
  model—this creates a soft dependency on Google Books data shapes, which
  is acceptable for a project of this scope.
