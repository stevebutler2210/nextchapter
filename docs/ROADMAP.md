# NextChapter — Future Roadmap

This document captures planned and potential future development,
organised by phase. It is a living document — items move between
phases as priorities and user feedback evolve.

---

## Phase 1 — Mobile feature parity

Mobile write actions are currently deferred — the app is read-only
beyond auth. Delivering these requires both new Rails API endpoints
and corresponding mobile screens.

Rails API work needed:

- POST /api/v1/cycles/:id/nominations — nominate a book
- POST /api/v1/nominations/:id/votes — cast a vote
- POST /api/v1/cycles/:id/reading_log_entries — log a reading note

Mobile work needed (dependent on API above):

- Nominate a book — book search modal, add to current cycle
- Cast a vote — vote action from club detail voting state
- Log a reading note — inline form on club detail reading state

Additional:

- Platform-specific design tightening — review and refine UI on both
  iOS and Android; address platform-specific layout or interaction
  inconsistencies surfaced by real-device testing

---

## Phase 2 — MVP hardening (pre-launch)

The app is feature-complete but not yet ready for public use.
Requires Phase 1 to be complete.

- App store registration and submission (iOS App Store, Google Play)
- Domain acquisition and email address configuration
- Define and document deployment workflows for both Rails and mobile
  in READMEs — including EAS build profiles, Fly deploy process,
  and credentials management
- Switch Fly machine from suspend-on-inactivity to always-on
- Book cover cache job — generate and store thumbnail variants;
  mobile client to use thumbnails rather than full-size covers
- Settings screen: password change, email change, account deletion,
  data export request
- Footer linked pages (Privacy, Terms, Contact) — hard-coded initially
- Contact form / report button

---

## Phase 3 — Reading experience depth

Core reading and club features that deepen engagement.

- Reading log history — top-level dashboard view, club-scoped drill-down
- Reading progress as percentage (for e-reader / Kindle users) alongside
  page count
- Enhanced group progress visualisation on the reading screen — who has
  started, who is partway through, who has finished
- Book review scores — quick rating on cycle close, full written review
  optional; likely phased
- Book review scheduling — in-app reminders free, calendar
  integrations (Google, Apple) as a pro feature
- Book review discussion questions — owners predefine questions,
  presented in-app and optionally emailed to members ahead of review

---

## Phase 4 — Discovery and social

Features that grow the network and help readers find each other.

- Public vs private clubs — public club search and open invites
- Pro tier: unlimited clubs (free tier capped at 1 per user)
- User profiles — post-public clubs; consider anonymous profile flag
- Goodreads / StoryGraph import — reading history, to-read list;
  viable as a pro feature if user traction warrants the integration cost

---

## Phase 5 — Platform and scale

Infrastructure and content management for a growing product.

- CMS-driven home screen book collage selection
- Better public-facing roadmap — platform with upvoting, comments,
  and phase visibility (e.g. Canny, Fider, or GitHub Discussions)
- Defined process for anticipating and acting on scaling needs —
  Fly autoscaling configuration, database volume monitoring,
  CDN for Active Storage assets
- Footer and marketing pages via CMS rather than hard-coded ERB

---

## Not scheduled

Items that are interesting but have no committed timeline:

- Ranked-choice or quadratic voting modes
- Push notifications for club activity
- Offline reading log entries (sync on reconnect)
