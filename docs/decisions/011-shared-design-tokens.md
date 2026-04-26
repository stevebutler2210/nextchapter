# ADR-011: Shared design tokens — private npm package on GitHub Packages

**Date:** 2026-04-25
**Status:** Accepted

## Context

NextChapter has two separate repositories (`nextchapter` and
`nextchapter-mobile`) that need to share the same colour and spacing values.
Without a single source of truth, the two codebases would drift—any token
change would need to be applied manually in both places.

Options considered:

- **Copy-paste / manual sync** — simple to set up, guaranteed to drift.
- **Git submodule pointing at a tokens repo** — avoids a registry but adds
  submodule management overhead and is awkward in CI.
- **Private npm package on GitHub Packages** — standard package consumption
  in both repos, one publish step to propagate changes, works in GitHub
  Actions CI with the existing `GITHUB_TOKEN`.

## Decision

Create `@stevebutler2210/nextchapter-design-tokens` as a private npm package
published to GitHub Packages. The package exports tokens in two formats:

- **`@theme` block** — for Tailwind v4 consumption in the Rails app
  (`app/assets/tailwind/application.css`).
- **`:root` CSS variables** — for consumption in the mobile app's `global.css`,
  bridged to RNR component variables.

Both consumers install the package and import the relevant export. CI on the
Rails side is green with the package consumed. Mobile hot reload confirmed
working with the `:root` variables live.

## Consequences

- Token changes require a package version bump and a `npm install` update in
  each consumer—a small amount of ceremony, but explicit and auditable.
- GitHub Packages auth is required in CI; handled via `GITHUB_TOKEN` in
  Actions—no additional secrets needed.
- The dual-export approach (`@theme` + `:root`) adds a small authoring
  overhead when adding new tokens, but keeps each consumer using its native
  import pattern rather than a workaround.
