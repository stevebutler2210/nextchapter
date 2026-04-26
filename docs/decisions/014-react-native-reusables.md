# ADR-014: Component library — React Native Reusables (Uniwind variant)

**Date:** 2026-04-25
**Status:** Accepted

## Context

The mobile app needed a component library to provide baseline UI primitives
(inputs, buttons, cards, badges, avatars) without hand-rolling them. The
goals were: Tailwind/utility-class compatible, well-structured for theming,
and fast to get working — the mobile build window is short.

Options considered:

- **Roll your own** — maximum control, but too slow for a short build window
  with only a handful of screens.
- **Gluestack UI** — solid, but more opinionated about its own theming system;
  bridging to our design tokens would add friction.
- **React Native Reusables (RNR)** — a React Native port of shadcn/ui. Component
  primitives are copied into the project (not installed as a black-box
  dependency), so they can be modified freely. Supports both NativeWind and
  Uniwind variants.

## Decision

Use React Native Reusables with the Uniwind variant. Install only the components
that are actually needed per screen; do not bulk-install the full library.

Earmarked per screen:

| Screen            | Components                                           |
| ----------------- | ---------------------------------------------------- |
| Sign in / Sign up | `Input`, `Label`, `Button`, `Text`, `Card`           |
| Clubs list        | `Card`, `CardHeader`, `CardTitle`, `Badge`, `Button` |
| Club detail       | `Card`, `Badge`, `Avatar`, `AvatarFallback`, `Text`  |
| Barcode scan      | `Button`, `Card`, `Text`                             |

## Consequences

- Components live in the project and can be modified without fighting a
  third-party API.
- Token bridging: RNR CSS variables are mapped to NextChapter design tokens
  in `global.css`, so the same colour and spacing values drive both the web
  and mobile surfaces.
- The "copy into project" model means RNR upstream changes are not
  automatically received; that's acceptable at this scale.
- ExpoUI / SwiftUI (beta, stable predicted mid-2026) was agreed but deprioritised,
  as an additional layer for native-feel elements. Risk accepted given the limited
  screen count and manageable breakage surface before stable ships. Conduct this pass
  only if / when other deliverables are complete
