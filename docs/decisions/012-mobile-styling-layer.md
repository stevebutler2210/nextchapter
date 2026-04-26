# ADR-012: Styling layer — Uniwind over NativeWind

**Date:** 2026-04-25
**Status:** Accepted

## Context

The mobile app needed a utility-class styling layer to match the `className`-based
approach used on the Rails side (Tailwind v4) and to consume the shared design
tokens package. NativeWind was the natural first choice—it is the most widely
used Tailwind-compatible layer for React Native and has good ecosystem support.

During setup, NativeWind's `react-native-css-interop` package threw an
`addedFiles` crash under Metro 0.83.6 (the version shipped with Expo 55 /
Ignite 11). The crash occurs during Metro's resolver phase and blocks the dev
client from starting. Downgrading Metro was considered and rejected—it would
conflict with Expo 55's expected resolver version and create a larger maintenance
surface.

## Decision

Replace NativeWind with Uniwind. Uniwind is a drop-in alternative that provides
the same API without a dependency on `react-native-css-interop`. It
is compatible with Metro 0.83.6.

## Consequences

- No change to component authoring—API is identical.
- React Native Reusables (RNR) has a Uniwind variant; this was used instead of
  the NativeWind variant.
- Design tokens from `@stevebutler2210/nextchapter-design-tokens` bridge into
  `global.css` using the same `@theme` / `:root` pattern as on the Rails side.
- If NativeWind ships a fix for the Metro 0.83.6 incompatibility in a future
  release, migration back is low-cost given the identical API surface.
