# NextChapter — Design System

## 1. What this document is for

This is the committed design record for NextChapter. It describes the visual language, token set, and component patterns to apply across the web application.

It is intended to be used alongside the Stitch reference screens (landing, dashboard, club nominating, club voting, club reading) as the authoritative guide for the styling pass.

This document does **not** describe planned or aspirational features. It describes what is built and how it should look.

---

## 2. What is built

NextChapter is a Rails 8.1 web application. The interface is server-rendered HTML delivered via Hotwire (Turbo Drive, Turbo Frames, Turbo Streams) with light Stimulus controllers. There is no client-side routing and no React. Designs must work within standard HTML/ERB patterns.

### Screens and flows in scope

| Screen | Path | Notes |
|---|---|---|
| Logged-out landing page | `/` (unauthenticated) | Marketing/welcome page; sign up and log in CTAs |
| Sign up | `/sign_up` | Email + password form |
| Log in | `/sign_in` | Email + password form |
| Dashboard | `/dashboard` | Lists the user's clubs with state badges |
| Club detail — Nominating | `/clubs/:id` (nominating state) | Club header (shared); search bar, nominations list |
| Club detail — Voting | `/clubs/:id` (voting state) | Club header (shared); nominations with Cast Vote buttons and vote counts |
| Club detail — Reading | `/clubs/:id` (reading state) | Club header (shared); current book callout, log-a-note form, reading log entries |
| Club creation | `/clubs/new` | Name and description form, opens in Turbo Frame on dashboard |
| Club edit | `/clubs/:id/edit` | Name and description, opens in Turbo Frame on club detail |
| Join via invite | `/invites/:token` | Accepts signed invite link; handles expired/invalid states |

### Club detail — shared header (all states)

All three club detail states share an identical header block above the state-specific content:

- Club name (headline scale)
- Club description (body copy)
- Member avatar row (circular initials, overlapping — see section 7)
- State badge (Nominating / Voting / Reading)
- "Copy Invite Link" button (see section 7)

### What is not built (do not invent these)

- Book detail pages
- User profile pages
- Notification centre
- Comments or threads
- Dark mode
- Native mobile views (that is a separate Expo app)

---

## 3. Design philosophy

The aesthetic is "Curated Tactile." It draws from high-end editorial print design: broadsheets, art books, literary journals. The goal is warmth and quiet confidence — not the sterile, templated look of generic SaaS.

Key principles:

- **No 1px divider lines.** Separation is achieved through background colour shifts and whitespace, never structural borders.
- **Whitespace is architecture.** Minimum 16px between elements; favour 64px+ between thematic sections.
- **Asymmetry over grids.** Hero and primary content blocks use 60/40 or 70/30 splits, not 50/50.
- **Primary colour is rare.** The clay-red (`primary`) is a moment of intent. Use it for one CTA per screen, not for decoration.
- **Dark mode is out of scope.** The palette is rooted in the warmth of physical paper.

---

## 4. Colour tokens

All tokens use hyphenated naming. These are the only colours to use — do not introduce values outside this set.

| Token | Hex | Role |
|---|---|---|
| `surface` | `#fcf9f5` | Primary page background — the "paper" base |
| `surface-container-lowest` | `#ffffff` | Elevated highlights; cards that should pop forward |
| `surface-container-low` | `#f7f4f0` | Secondary regions; subtle depth |
| `surface-container` | `#f0ede9` | Standard container background |
| `surface-container-high` | `#e5e2de` | Nested elements; utility panels |
| `surface-container-highest` | `#dbd8d4` | Maximum tonal depth |
| `surface-variant` | `#e1ddd8` | Alternative tonal surface |
| `on-surface` | `#1c1c1a` | Primary text; high legibility |
| `primary` | `#89453a` | Clay-red; moments of intent only |
| `primary-container` | `#f4ebe9` | Soft wash behind primary highlights |
| `on-primary` | `#ffffff` | Text on primary backgrounds |
| `tertiary` | `#7a826e` | Organic sage; subtle accents and tertiary actions |
| `tertiary-container` | `#eff1ed` | Soft wash for tertiary highlights |
| `outline` | `#85827e` | High-contrast structural boundary (rare) |
| `outline-variant` | `#d1cfcc` | Low-contrast boundary; ghost borders on inputs |

### Surface hierarchy in practice

Think of the interface as a physical stack of paper:

- **Base:** `surface` for the main page background
- **Cards / focal areas:** `surface-container-lowest` (`#ffffff`) to lift forward
- **Secondary panels, sidebars, footers:** `surface-container-high` to recede

---

## 5. Typography

Fonts are loaded via **Google Fonts**. No self-hosted font files are required.

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Newsreader:ital,opsz,wght@0,6..72,300..800;1,6..72,300..800&family=Work+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
```

### Type roles

| Role | Font | Size | Weight | Use |
|---|---|---|---|---|
| `display-lg` | Newsreader | 3.5rem | 400 | Page hero headline |
| `headline-md` | Newsreader | 1.75rem | 400 | Section entry points, club names at large scale |
| `headline-sm` | Newsreader | 1.25rem | 400 | Card titles, secondary headlines |
| `body-lg` | Work Sans | 1rem | 400 | Standard reading copy |
| `body-sm` | Work Sans | 0.875rem | 400 | Secondary descriptive text |
| `label-md` | Work Sans | 0.75rem | 500 | Uppercase metadata, state badges, button labels |

### Rules

- Newsreader is for headlines and moments. Work Sans is for everything functional.
- Use straight apostrophes (`'`) throughout all copy.
- UK English: colour, favour, organisation, cancelled.

---

## 6. Spacing

Base unit: **4px**.

All padding, margin, gap, and component heights must be multiples of 4px.

| Scale | Value | Common use |
|---|---|---|
| `space-1` | 4px | Tight internal padding |
| `space-2` | 8px | Component internal gap |
| `space-3` | 12px | |
| `space-4` | 16px | Minimum separation between elements |
| `space-6` | 24px | Standard section padding |
| `space-8` | 32px | Larger content blocks |
| `space-12` | 48px | Section separation |
| `space-16` | 64px | Thematic section breaks |

---

## 7. Components

### Buttons

- **Corner radius:** 2px (`rounded-sm`). Sharp and tailored — never bubbly.
- **Primary button:** `primary` background, `on-primary` text. One per screen maximum. Used for the single most important action.
- **Secondary / ghost button:** `surface-container` background or transparent, `on-surface` text, `outline-variant` ghost border.
- **Tertiary / text button:** No background. `tertiary` colour. `label-md` weight.
- **Destructive:** Reserve for owner-only destructive actions (delete club). Use `on-surface` text with no background unless emphasis is needed.

### Inputs and form fields

- Background: `surface-container`
- Border: ghost border using `outline-variant` at low opacity — not a heavy 1px solid
- Corner radius: 2px, matching buttons
- Focus state: subtle outline in `primary` colour
- Labels: `label-md`, `on-surface`
- Error text: below the field, `body-sm`, distinct colour (use `primary` or a dedicated error token if added)

### Cards

- Background: `surface-container-lowest` on a `surface` or `surface-container-low` base
- Corner radius: 4px
- No border lines. Depth from background shift only.
- Internal padding: `space-6` (24px) minimum

### State badges (cycle states)

Three states exist: **Nominating**, **Voting**, **Reading**. These appear on club cards on the dashboard and on the club detail header.

- Pill shape, `label-md`, uppercase
- Nominating: `tertiary-container` background, `tertiary` text
- Voting: `surface-container-high` background, `on-surface` text
- Reading: `primary-container` background, `primary` text

### Navigation sidebar (authenticated)

The dashboard and club views use a left sidebar. Items: Dashboard, Log Out. Active item uses `primary-container` background. Width: fixed, ~160px.

### Book cover placeholders

Books may have cover images (fetched from Google Books via Active Storage). When no image is available, show a placeholder block in `surface-container-high` with a small book icon or the initial letter of the title — not a broken image element.

### Member avatars

Club detail pages show member initials in a row of circular, overlapping avatar chips. Initials are derived from the user's display name.

**Prerequisite:** A `name` field must be added to `User` before this component can be implemented. This is a Day 6 prerequisite ticket — a required string field collected at sign-up. Until it exists, the avatar row cannot render meaningfully. Do not fall back to email addresses as a source for initials in the UI.

### Invite link

A "Copy Invite Link" button on the club detail header. The full URL is never displayed in the UI. On click, the Stimulus `clipboard` controller copies the signed invite URL to the clipboard and updates the button label to "Copied!" for 2 seconds before reverting. This controller is already implemented.

---

## 8. Empty states

Every list view needs an empty state. These are the cases that exist:

| View | Empty condition | Suggested treatment |
|---|---|---|
| Dashboard — clubs list | User has no clubs | Illustration or icon; prompt to create first club; "Create Your Club" primary CTA |
| Club — nominations list | No nominations yet | Short prompt encouraging first nomination; direct attention to the search bar |
| Club — votes list | No votes cast yet | Short prompt; no action needed from the reader (voting is optional) |
| Club — reading log | No log entries yet | Short prompt; direct attention to the "Log a note" form |

Empty states should feel warm, not like error pages. Use Newsreader for any headline text within the empty state. Keep copy concise.

---

## 9. Error states

### Book search (external API)

The book search calls the Google Books API. Three error conditions need UI treatment:

| Condition | Cause | Treatment |
|---|---|---|
| Short query suppressed | Query under ~3 characters; debounce fires before meaningful input | No message shown — results area stays blank or shows previous results |
| No results found | Valid query, API returns empty | Inline message within the results area: "No books found for '[query]'. Try a different title or author." |
| API error | Network failure or Google Books unavailable | Inline message: "Book search is unavailable right now. Try again in a moment." — do not flash the full page |

Error messages appear **inline** within the Turbo Stream target (`#book-results`), not as full-page flash banners.

### Form validation errors

Standard Rails model validation errors. Display inline below each field. Summary at top of form is acceptable but not required.

### Invite link states

The invites flow handles these states (already implemented — style only):

- **Valid:** Accepted, redirect to club
- **Expired or invalid token:** Error message, link back to dashboard or sign-up
- **Already a member:** Informational message, link to the club

### Cycle transition errors

Owner-only actions (close nominations, close voting) can fail if preconditions aren't met (e.g. no nominations to close, no votes cast). These surface as flash messages on the club page — style the flash component accordingly.

---

## 10. Flash and notice messages

Flash messages are set by the controller and rendered server-side. They appear as a dismissible banner, typically below the navigation bar.

Two variants:

| Variant | Token | Use |
|---|---|---|
| Notice | `tertiary-container` background, `tertiary` text | Success confirmations, informational |
| Alert | `primary-container` background, `primary` text | Errors, warnings, precondition failures |

### Cycle transition flash messages

The cycle state transition actions produce flash messages that must be styled. Specific strings:

| Event | Variant | Message |
|---|---|---|
| Voting closed, winner selected | Notice | "Voting closed. '[Book Title]' will be your next read." |
| Voting closed, tie broken randomly | Notice | "It was a tie — '[Book Title]' was selected at random." |
| Nominations closed | Notice | "Nominations closed. Time to vote." |
| Transition failed (wrong state, no nominations, no votes) | Alert | Set by the controller per condition |

These replace any browser `alert()` calls. No modal, no animation. Styled consistently with all other flash output.

---

## 11. Logged-out landing page

The root path (`/`) shows a marketing page to unauthenticated visitors. The page has four sections:

1. **Hero** — headline, subheadline, Sign Up and Log In CTAs. Asymmetric layout (text left, visual right). Visual is a collage of book cover colour blocks — not photos.
2. **Features** — three-column row: "Form a Club", "Nominate & Vote", "Track Together". Each with a small icon and two lines of copy.
3. **Quote / philosophy pull** — a centred editorial quote in Newsreader at display scale. Attributed to a fictional journal ("The Curated Folio Journal").
4. **Footer CTA** — full-width band in `surface-container-high`: "Start your next chapter today." with a single "Create Your Club" primary button.

Navigation bar: logo left, "Log In" and "Sign Up" right. Sign Up uses the primary button style.

Footer: minimal. Logo, a few links (Privacy, Terms, Contact), copyright line.

---

## 12. Motion

Motion is invisible. It should feel like a page turn, not an animation.

- Transitions: linear fades, 200ms–300ms only
- No bounce, no elastic, no snap
- Turbo Drive page transitions should feel instant

---

## 13. Do / Don't

### Do
- Use whitespace instead of lines for separation
- Apply 2px radius to all interactive elements
- Use UK English throughout
- Keep `primary` colour rare — one CTA per screen
- Align everything to the 4px grid

### Don't
- Use 1px solid borders to section content
- Use 50/50 grid splits
- Use dark mode or invert the palette
- Show broken image elements — always fall back gracefully
- Invent screens, flows, or features not listed in section 2
