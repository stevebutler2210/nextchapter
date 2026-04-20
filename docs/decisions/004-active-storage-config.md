# ADR-004 — Active Storage storage backend

Status: Accepted
Date: 2026-04-19

**Note:** ADR format will include alternatives considered section going forwards
where appropriate. Status update date will also be included.

## Context

Book cover images are downloaded from Google Books and attached via Active
Storage. A storage backend is required for both development and production.

## Decision

Use local disk storage in development and a Fly.io persistent volume
(`/data/storage`) in production.

## Alternatives considered

- **Amazon S3** — reliable and scalable, but adds cost and requires managing
  AWS credentials. Not justified for a demo-scale project.
- **Google Cloud Storage** — similar trade-offs to S3; also ties to a second
  GCP dependency alongside an already-used Google Books API key.

## Consequences

- No additional cost or credential complexity at demo scale.
- The Fly.io volume is already present for SQLite; storage reuses it.
- Does not scale horizontally. Acceptable given scope; noted as a known
  limitation for production use beyond demo scale.
