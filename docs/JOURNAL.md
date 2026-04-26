## Day 0 - 17/04/2026 - Planning

Created both repositories. Committed PLAN.md and WORKFLOW.md to
`nextchapter-mobile/docs/`. Set up a public GitHub Project board with both
repos linked. Added labels, milestones, and issue templates to
`nextchapter-mobile`. Filed the mobile ticket stubs (11 issues).

Backend ticket stubs were not filed—deferred to Day 1 morning. No code
shipped.

## Day 1 - 18/04/2026 - Foundations

**Shipped**

- Rails 8.1.3 / Ruby 3.4.9 app initialised—upgraded from the plan's 3.3 /
  8.0 targets. Rails 8.0.x moves to security-only support in May 2026; 8.1.3
  is current stable. Ruby 3.4.9 preferred over 4.0 on gem stability grounds.
  (ADR-001)
- `rails new` run with `--ci=github` to get a working Actions scaffold from
  the start; `--css` omitted
- Empty `test/system` directory with keepfile added to ensure CI system-test
  step passes without a rewrite later
- GitHub Actions CI green: test, system-test, lint, scan_ruby, scan_js all
  passing on PR
- Authentication via Rails 8 generator, with the following additions:
  - 12-character password minimum (no complexity rules)
  - `reset_session` on sign-in to mitigate session fixation
  - Email uniqueness validated at model layer
  - `created_at` on the Sessions table—commented as a day 7 hardening
    reminder for future session expiry sweeps
  - `force_ssl` considered and deferred—Fly.io handles SSL termination
- Club and Membership models with migrations (ADR-002)
- Seed script: sample club, two users, a cycle mid-voting, book data
- ADR-001 (stack and infrastructure) and ADR-002 (initial data model)
  committed to `docs/decisions/`—individual files rather than a single
  DECISIONS.md, following Nygard's original format
- Test fixtures kept over Factory Bot—appropriate for this scope
- Skeleton deployed to nextchapter.fly.dev. Two Dockerfile issues surfaced
  and fixed: `/rails` chown scope too narrow; Thruster removed in favour of
  Rails serving directly on port 8080 (non-root user can't bind to port 80)
- Branch protection and squash-merge enforced on main

**Deferred**

- Backend ticket stubs for days 2–9 not filed—carrying forward to Day 2
  morning
- JOURNAL Day 1 entry written the following morning

**Surprises / deviations**

- Ruby and Rails versions both bumped from plan (see above)—no downstream
  impact on day 1 scope
- Two Fly.io deployment issues added some time; both resolved and documented
  in ADR-001
- Root route is a temporary placeholder (`sessions#new`) rather than an
  authenticated dashboard—intentional day 1 shortcut

**Open questions into Day 2**

- Credentials setup deferred to planned Day 7—ticket notes to be updated when
  filing stubs today
- `force_ssl` revisit flagged for planned Day 7 depending on deployment setup

## Day 2 - 19/04/2026 - Clubs and Membership

**Shipped**

- Backfilled JOURNAL entries for Days 0 and 1
- Full tickets written for Day 2; stubs filed for Days 3–9 including
  a Day 9 TODO sweep ticket
- Extra ticket added: skip CI on docs-only PRs (`paths-ignore` fix)
- Authenticated dashboard replacing the temporary root route placeholder
  from Day 1; sign-out link added to layout
- Club CRUD: scoped index, create with transaction, show, edit, update,
  destroy. Owner-only enforcement via `before_action`. Turbo Frame for
  the new club form (loads in-place, updates list on success). Edit form
  loads in-place on the detail page via a named frame.
- Signed invite links via `signed_id(expires_in: 1.week)`. Separate
  `InvitesController` handling valid, expired/invalid, already-a-member,
  and unauthenticated scenarios. `request_authentication` overridden for
  contextual flash. `return_to` preserved across `reset_session`.
- First Stimulus controller: clipboard copy button on club detail page.
  Reads URL from a `source` target span, updates button text to "Copied!"
  for 2 seconds on success.
- ERB excluded from Prettier via `.vscode/settings.json`
  after formatter was mangling indentation on save
- Request tests for `ClubsController` and `InvitesController`. All
  passing.

**Deferred**

- Stimulus controller system test deferred to planned Day 6 polish/test pass—
  noted on that ticket

**Surprises / deviations**

- Prettier/ERB formatter conflict consumed ~45 minutes. Root cause: the
  `bung87.rails` VS Code extension was formatting ERB on save independently
  of Prettier. Resolved by disabling format-on-save for ERB in
  `.vscode/settings.json`.
- `return_to` was being wiped by `reset_session` on sign-in—required a
  stash-and-restore pattern in `SessionsController` to preserve post-login
  redirect for invite links.
- Day 2 completed ~30 minutes inside the planned window despite the
  formatter issues.

**Planning note**

Reviewed remaining day scoping against actual pace. Days 3 and 4 are
the best pull-ahead opportunities. Day 8 (mobile auth + JWT plumbing)
is the highest-risk day. Decision: pull Day 3 forward to this evening
as a focused session to bank time before the week's 3-hour day blocks.
Total hours ceiling revised to ~40 to preserve the "delivered in a
working week" narrative without compromising on quality.

**Open questions for Day 2 (Evening)**

- Turbo Streams spike needed before live book search implementation
- Solid Queue guide needed before cover image caching job
- Google Books API key setup required—confirm credentials approach
  before starting `BookLookupService`

## Day 2 (Evening) - 19/04/2026 - Books and External Lookup

**Shipped**

All planned Day 3 tickets closed:

- `Book` model with Google Books fields, unique index on `google_books_id`,
  title presence validation. Uniqueness enforced at both DB and model level—DB
  index is the hard constraint; model validation gives a cleaner error
  before it hits the database. Fixtures updated with API-verified data:
  Oathbringer and The Handmaid's Tale.
- `BookLookupService` wrapping the Google Books API via Faraday. Two public
  class methods: `search(query)` and `find_by_isbn(isbn)`. Results returned
  as `BookLookupService::Result`—a nested `Data` class rather than
  `Struct`. `Data` is immutable and uses keyword arguments; `Struct` had no
  advantage at this scope. Connection injected via keyword argument for
  testability without monkey-patching.
- Live search-as-you-type on `GET /books/search` via Turbo Streams. Controller
  responds to both `format.html` (full-page baseline, progressive enhancement)
  and `format.turbo_stream` (in-place update). Stimulus `book-search`
  controller debounces input at 300ms and calls `requestSubmit()` so Turbo
  intercepts the submission—plain `submit()` bypasses Turbo and causes a
  full-page reload.
- Active Storage `has_one_attached :cover_image` on `Book`. `cover_image_url`
  helper returns the Active Storage blob path if attached, falls back to
  external `cover_url`, falls back to nil. Same method added to
  `BookLookupService::Result` (returning `cover_url` directly) so the
  `_results` partial works with both objects without type-checking.
- `CacheCoverImageJob` via Solid Queue. Downloads and attaches cover images
  in the background. Skips quietly if book not found, `cover_url` blank, or
  attachment already present. Rescues `StandardError` without re-raising—
  raising would cause Active Job to retry indefinitely on a permanently bad
  URL.

ADR-003 (Google Books API choice) committed. ADR-004 (Active Storage storage
backend) to be written at start of Day 4.

**Deferred**

- `CacheCoverImageJob` call site deferred to Day 4—the job exists and is
  tested but nothing enqueues it yet. Natural home is wherever a book is
  first persisted from search results.
- Turbo progress bar styling deferred to planned Day 6—noted on the styling ticket.

**Surprises / deviations**

- `turbo_stream.replace` broke subsequent searches by removing the `#book-results`
  target element from the DOM. Switched to `turbo_stream.update`.
- Minitest 6 was pulled in as a transitive dependency and removes `minitest/mock`
  to favour a standalone gem (`minitest-mock`) that isn't yet stable. Pinned to
  `~> 5.25`. Revisit when `minitest-mock` has stabilised.
- Solid Queue required a separate queue database entry in `database.yml` for
  development—the production multi-database config doesn't translate directly
  because development previously used a single SQLite file. `bin/dev` rebuilt
  as a Foreman setup to run web and worker processes together.

**Open questions into Day 4**

- ADR-004 (Active Storage storage backend) to be written before starting tickets
- `CacheCoverImageJob.perform_later` call site to be wired in when books are
  first persisted from search results

## Day 3 - 20/04/2026 - Cycles and Nominations (Partial)

**What shipped**

- ADRs 004, 005, and 006 written and committed. ADR-001 addendum
  considered—made it ADR-006 instead to keep approved ADRs immutable.
  Dates corrected to reflect when decisions were actually made (Day 3),
  not when the ADRs were committed.
- ADR format reconciled across all six files—status line standardised
  to plain `Status: Accepted`.
- `page_count` added to `Book` and `BookLookupService::Result`. Google
  Books can return 0 as a page count—handled with `presence&.positive?`
  in the partial rather than a bare nil check.
- `Cycle` model with string enum states, explicit transition methods
  that raise on invalid transitions, and one-active-cycle-per-club
  enforced at both model and DB level via a partial unique index. Landed
  on the built-in uniqueness validation with a `conditions` lambda.
- `Nomination` model joining Book, Cycle, and User. Two uniqueness
  constraints: one nomination per user per cycle, and one nomination per
  book per cycle—the second was added during implementation and wasn't
  in the original spec.
- `BookFindOrCreateService` created to own find-or-create logic and job
  dispatch rather than putting that logic in the controller.
- Appropriate `dependent:` options added across associations after
  working through the deletion semantics.

**Deferred**

- Nomination UI and Turbo Stream broadcast—planned Day 4 started late; both
  tickets carry forward to planned Day 5 morning before evening work begins.

**Surprises or deviations**

- `page_count` nil check required `presence&.positive?` rather than a
  simple nil guard—Google Books returns 0 for some entries.
- Unique constraint on `[cycle_id, book_id]` added to nominations during
  implementation—not in the original spec but the correct behaviour for
  a book club app.

**Open questions into Day 5**

- Nomination UI and Turbo Stream broadcast tickets carry forward—start
  these before picking up planned Day 5 work.

## Day 4 - 21/04/2026 - Voting UI and Live Updates

### What shipped

- Design exploration using Google Stitch—four screens (landing, dashboard, club nominating/voting/reading) added to project files as working references. DESIGN.md drafted but not committed; authoring it properly by hand is a planned Day 6 ticket.
- All planned Day 5 tickets expanded from stubs into full specs, plus a planned Day 6 DESIGN.md ticket stubbed.
- Day 4 carryover: nomination UI—search, nominate, and update nominations on the club show page. Turbo Stream broadcast of new and updated nominations to all connected club members via Solid Cable.
- Vote model with denormalised `cycle_id` for a database-level one-vote-per-user-per-cycle constraint. `before_validation` callback populates `cycle_id` from the nomination automatically.
- Voting UI with live tally. Cast Vote / Remove Vote as separate controller actions. Vote counts broadcast to all connected members via `BroadcastVoteTallyJob` and a dedicated `_vote_count` partial.
- Presenter layer introduced—`ApplicationPresenter` base class, `NominationPresenter` handling vote button logic and disabled state. `ApplicationHelper#present` for clean instantiation in views.
- Solid Cable configured for development. Cable database added to `database.yml`, `cable_schema.rb` loaded manually (Rails `db:reset` doesn't load it automatically—README note queued for Day 6).
- Club creation now includes an initial nominating cycle inside the existing transaction.
- Seeds updated with cycle creation; stale TODOs removed.

### What was skipped or deferred

- Four planned Day 5 tickets remain: close-voting, cycle transition to reading, ReadingLogEntry, and Active Record Encryption. These were always the second half of the planned scope.
- Request tests for voting UI are in but system-level broadcast tests are deferred to the planned Day 5 system test pass.
- Voting UI PR raised but not merged—reviewing with fresh eyes tomorrow.

### Surprises and deviations

- Solid Cable required manual setup that wasn't generated on Day 1—`cable_schema.rb` exists but `db:reset` doesn't load it. Root cause: Action Cable wasn't exercised until planned Day 5 scope, so the gap was invisible. Lesson for future projects: smoke-test infrastructure on Day 1 even if the feature isn't built yet.
- `after_create_commit` on Vote was unreliable in the Solid Cable/SQLite threading context—the callback fired inside a `SolidCable::TrimJob` thread and was silently swallowed. Moved vote tally broadcasts to an explicit job dispatched from the controller. Nomination broadcasts remain as model callbacks (they work correctly in the simpler create-only flow).
- Collection partial rendering with the shorthand `render @collection, locals:` does not reliably forward locals to each iteration. Switched to explicit `render partial:, collection:, as:, locals:` form.
- Tie-break rule changed from earliest-nomination-wins to random selection between tied nominations. Not yet implemented—first planned Day 5 ticket tomorrow covers this.

### Open points into Day 5

- Four remaining planned Day 5 tickets—close-voting, reading transition, ReadingLogEntry, encryption. Scope is recoverable: planned Day 3 work was pulled forward into Day 2's evening session, so the schedule has flex.
- Voting UI PR needs a fresh-eyes review before merge.
- `db:reset` + `cable_schema.rb` manual step needs documenting in the README (Day 6 deploy hardening).
- `voted_by?` and the presenter's `cycle.votes.exists?` both fire per-row queries. Acceptable at current scale but worth revisiting if nomination counts grow. Counter cache is the likely fix.

## Day 5 - 22/04/2026 - Cycle Transitions, Reading Logs, and Encryption

### What shipped

All four planned Day 5 carryover tickets closed, plus the voting UI minor refactor (#83):

- **Voting UI refactor** — ownership check added to vote destroy, superfluous `reload` removed, vote lookup refactored to use `detect`, error handling added for missing votes in `VotesController`.
- **`close_voting_and_select_winner!` on `Cycle`** — sets `winning_nomination_id`, transitions directly from voting to reading in one step. Tie-break by random selection among tied nominations. Returns a `:tie` / `:winner` symbol so the controller can set an appropriate flash without the model knowing about flash. `COUNT(votes.id)` used in the left-join aggregate—`COUNT(*)` was counting the nomination row itself for zero-vote nominations, not actual votes.
- **State transition UI** — `close_nominations` and `close_voting` PATCH actions added to `CyclesController`, owner-only. Transition buttons rendered on the club show page for nominating and voting states. Club page subscribes to a club-level Turbo stream; `broadcast_action_to` with `action: :refresh` forces a full page reload for all connected members on state change. 303 See Other used for all transition redirects, including `RuntimeError` rescue paths. Request test coverage added for close-nominations and close-voting: success, forbidden, wrong-state, no-nominations, and no-votes paths.
- **`ReadingLogEntry` model, controller, routes, and reading-state partial** — immutable log entries with explicit string enum states (`started`, `progressed`, `finished`). Validations: cycle must be in reading state; `page_reached` must be a positive integer when present and cannot exceed the winning book's page count. `ReadingLogEntriesController#create` with membership-scoped cycle lookup and member-only access. Nested route under cycles (shallow, create-only). Turbo Frame for the log form and entry list — form clears after successful create. Per-user stream considered and rejected as over-engineering for a private personal log.
- **Active Record Encryption on `note`** — encrypts `:note` field on `ReadingLogEntry`. Non-deterministic (no lookup requirements on this field). Keys stored in `credentials.yml.enc`. `encrypt_fixtures: true` added to the test environment. Production key setup deferred to Day 6.

### What was skipped or deferred

- Style pass, system tests, empty states, landing page, and DESIGN.md commit — all carry into Day 6.
- `advance_to_voting!` callsite wiring — fold into Day 6 polish pass.
- Production encryption key setup on Fly — Day 6 deploy hardening.
- Service object extraction for cycle transitions — noted as Day 6 cleanup.

### Surprises and deviations

- `close_voting_and_select_winner!` guard logic had a subtle bug — left-join with `COUNT(*)` returned 1 for nominations with zero votes. Fixed by using `count("votes.id")` which only counts non-NULL join values.
- Turbo broadcast approach for state transitions iterated before landing on `broadcast_action_to` with `action: :refresh`. The simpler answer was available all along but took some exploration to get there.
- `rescue_from RuntimeError { }` syntax error in `CyclesController` — curly-brace form parsed incorrectly by Ruby. Switched to `do...end`.

### Open questions into Day 6

- `advance_to_voting!` callsite still unwired — fold into Day 6 polish pass.
- `dom_id` helper usage audit — some places may be using string interpolation where the helper should be used.
- DESIGN.md needs committing as the canonical design record before the style pass begins.
- Font imports (Newsreader, Work Sans) — confirm Google Fonts vs self-hosted before applying design tokens.
- `db:reset` + `cable_schema.rb` manual step still needs README documentation.

## Day 6 - 24/04/2026 - UI Polish and Design System

### What shipped

**Design system (DESIGN.md + Claude Design)**
`docs/DESIGN.md` committed as the canonical design record — tokens,
typography, spacing, component patterns, empty states, error states,
flash messages, and the logged-out landing page. Design references
produced in Claude Design (landing, dashboard, club detail × 3 states,
book search, flash banner, sign up / log in) and stored in
`docs/design_references/` as implementation guidance. All five Stitch
screens uploaded as visual baseline. Claude Design kept constrained to
`docs/DESIGN.md` throughout — no invented features or off-token values.

**Tailwind v4 + `nc-` design system**
`tailwindcss-rails ~> 4.4` added. Tokens defined in
`app/assets/tailwind/application.css` via `@theme` with a comment
block prohibiting unauthorised additions. Component styles use `nc-`
prefix across `application.css`, `auth.css`, `club_detail.css`,
`dashboard.css`, and `landing.css`. Type scale defined as reusable
`nc-type-*` utility classes. `nc-` prefix keeps product styles
distinct from Tailwind utilities and third-party defaults. Token
values must be defined in `docs/DESIGN.md` first.

**Public/auth shell split**
Root route moved to `HomeController#index` — authenticated users
redirect to clubs. New public landing page with hero, feature cards,
pull quote, and footer CTA. Application layout branches into sidebar
nav (authenticated) or public wrapper. Logout redirects to root.

**Landing page collage — real book covers**
`featured` boolean and `featured_index` integer added to `Book`.
`db/seeds/collage_books.rb` seeds 9 curated books via
`BookLookupService.find_by_isbn` and enqueues `CacheCoverImageJob`
for each. `db/seeds.rb` restructured: collage seed runs in all
environments; development fixtures gated on `Rails.env.development?`.
`HomeController` queries `Book.where(featured: true)` ordered by
`featured_index` with `Arel.sql` null-safe ordering. Landing page
ERB renders cover images with colour block fallback.

**User `name` field**
NOT NULL column with safe backfill migration using a local
`MigrationUser` class to avoid model coupling. Name derived from
email local part for existing rows. Validation, registration form,
seeds, and fixtures updated. Powers nomination attribution and avatar
chips. Email encryption deferred as a separate hardening ticket.

**Member avatars and `UserPresenter`**
Initials-based avatar chips with deterministic tone variants and a
CSS-only hover tooltip via `data-name` attribute and `::after`
pseudo-element. `BroadcastClubMembersJob` refreshes the avatar row
via Turbo on invite acceptance.

**Reading log form**
Note is the primary field; `page_reached` de-emphasised to a
secondary input. Finished checkbox auto-sets state to `finished`;
first entry defaults to `started`; subsequent entries default to
`progressed`. Controller derives state from the flag and existing
entry count.

**Database integrity**
`cycles.winning_nomination_id` FK updated to `on_delete: :nullify`
at the database level — more robust than a Rails callback as it
fires regardless of how the deletion happens. Winning nomination
presence validation scoped to `create`/`update` only.

### Deferred to Day 7

- Ticket #77: suppress book search error flash on rapid input / short queries
- Ticket #91: cycle closing and next-cycle creation
- Ticket #42: system tests — club creation, nomination, voting
- Email encryption (separate hardening ticket)
- `db:reset` + `cable_schema.rb` README documentation
- Breakpoint audit and named responsive scale in DESIGN.md
- Production encryption key setup on Fly

### Surprises and deviations

- Tailwind v4 uses CSS-based `@theme` config rather than
  `tailwind.config.js` — Copilot initially generated a v3 config
  file; corrected early in the session.
- `on_delete: :nullify` migration required after `ActiveRecord::
InvalidForeignKey` on club destroy in reading state — `winning_
nomination_id` still referenced a nomination being destroyed.
  Database-level constraint is the correct fix over a Rails callback.
- `nc-avatar:hover::after` selector had no effect — class mismatch
  with `nc-avatar-chip`. One-line fix.
- Column offset CSS for the landing collage had duplicate

## Day 7 - 25/04/2026 - Nav refresh and error pages

### What shipped

- Nav / logged-out header refresh — updated navigation layout and favicon
  (PR #101, squash-merged to main)
- 404 and 500 error page designs generated in Claude Design, ready for
  implementation in an upcoming ticket

### Deferred to Day 8

Lighter day by design — social plans meant a reduced session. The following
carry forward to Day 8:

- #77 — suppress book search error flash on rapid input / short queries
- #91 — cycle closing and next-cycle creation
- #42 — system tests: club creation, nomination, voting
- #47 — JSON API endpoints for mobile client
- #48 — custom 404/500 pages and production polish (designs done)
- #51 — Sentry error reporting
- #49 — docs: README polish
- #50 — docs: review and tidy JOURNAL.md
- #52 — feat(backend): GraphQL endpoint alongside REST
- Email encryption hardening, breakpoint audit, `db:reset` + `cable_schema.rb`
  README, production encryption key setup on Fly

### Surprises and deviations

None. Intentionally light session — Thursday had been a late night and Friday
was a social evening.

### Open questions into Day 8

- #91 cycle closing logic still needs careful thought before touching—state
  machine complexity flagged in Day 7 kickoff
- Mobile companion milestone (#8) is now the active sprint; JSON API and
  mobile scaffold are the priority thread

## Day 8 — 25/04/2026 — Mobile companion, part 1

**Shipped**

**Rails side**

- **#77** (search error flash suppression) Book search no longer
  flashes an error on rapid input or queries below the minimum length threshold.
- **#91** (cycle closing and next-cycle creation)Full state
  transition sequence implemented with guard conditions. API response shape
  accounts for closed-cycle state so mobile screens have a consistent contract
  to build against.
- **#47** (REST API) JSON endpoints built for auth, clubs, current
  cycle, nominations, and book lookup. Documented via Swagger using `miniswag`.
  Smoke-tested with curl and covered with minitest. Dedicated `jwt_token` secret
  added to Rails credentials via `SecureRandom.hex(64)`; production secret set
  separately at the same time.

**Mobile scaffold and infrastructure**

- **Mobile #1** Expo 55 project scaffolded via Ignite 11 generator.
  Obytes starter considered and rejected—too opinionated on auth and routing,
  and no prior experience with it. Strategy: strip only the demo screen and dead
  translations; re-evaluate component usage at end of week.
- NativeWind selected initially as the styling layer, then rejected mid-session
  after hitting a `react-native-css-interop` `addedFiles` crash under Metro
  0.83.6. Replaced with Uniwind—a drop-in alternative with the same
  API. React Native Reusables (RNR) installed with the Uniwind variant.
- Design tokens package (`@stevebutler2210/nextchapter-design-tokens`) created
  as a private npm package on GitHub Packages. CSS `@theme` + `:root` dual-export
  allows both Rails and mobile to consume the same token values. Rails CI green;
  mobile hot reload confirmed working. Setting up additional libraries (ExpoUI)
  in flight at end of day.
- **Mobile #2** (README) — drafted during session; pending final
  review at start of Day 9.

**What was skipped or deferred**

- **Mobile #3–#7** (auth screens through club detail) not started.
  Infrastructure work (NativeWind → Uniwind migration, RNR setup, design tokens
  package) consumed more of the session than anticipated. All carry to Day 9.
- ExpoUI / SwiftUI install—agreed but not done; carry to Day 9 morning.
- Barcode scan-to-nominate (#9) demoted to tier 2. Rest of mobile app is read-only for the
  initial build. Allows a leaner, more coherent experience to ship on Day 9
  without the scan-to-nominate flow becoming a blocker.
- **#48** (custom 404/500 pages), **#42** (system tests), **#51** (Sentry),
  **#49/#50** (docs), email encryption hardening—all still carried.

**Surprises and deviations**

- NativeWind incompatibility with Metro 0.83.6 was not anticipated. Debugging
  and evaluating the Uniwind replacement added roughly an hour to the session.
  Uniwind turned out to be a clean swap with no API differences, so no rework
  downstream.
- Design tokens package took longer than estimated, primarily due
  to GitHub Packages auth setup and confirming the dual-export approach worked
  in both consumers before committing to the strategy.
- GraphQL (#52) descoped entirely—REST serves mobile needs; GraphQL would add
  complexity without a consumer at this stage. ADR to be written.

**Open questions into Day 9**

- Mobile #2 README — confirm it's accurate against what actually ships before
  closing the ticket.
- ExpoUI / SwiftUI — install before any screen work begins.
- JWT auth implementation (#3/#4) is the highest-risk work remaining; approach
  discussion before any code.

## Day 9 - 26/04/2026 - Mobile companion, part 2

**Shipped**

**Mobile**

- Firmed up mobile UI approach—SwiftUI/ExpoUI pass deprioritised;
  deferred to post-write-actions milestone as the screen count is small
  enough that the risk/reward doesn't justify it during the initial build
- All Day 9 mobile screens built and working against the live Rails API:
  sign in, sign up, clubs list, club detail (all three cycle states),
  and a profile stub with sign out
- JWT auth with Zustand store, SecureStore persistence, and automatic
  token refresh via Axios interceptor—full auth lifecycle working
  including token expiry handling
- Design tokens package (`@stevebutler2210/nextchapter-design-tokens`)
  updated to v0.2.0—added a TypeScript export alongside the existing
  CSS export, so token values are available for imperative React Native
  code (StyleSheet, props, tintColor etc) as well as Uniwind className
  usage
- Mobile CI added—lint check on PR and push to main via GitHub Actions.
  Decision to add this earlier than planned (original plan was to defer
  until Maestro system tests): a stale `setToken` reference slipped
  through a refactor that a lint check would have caught. Low-cost safety
  net, added immediately
- Mobile app architecture patterns established:
  - `src/app/**/*`—route wrappers, data fetching, refresh logic
  - `src/screens/**/*`—presentational layer per screen
  - `src/components/**/*`—reusable building blocks; RNR components
    under `ui/` subdirectory
- Updated mobile app icons and splash screen assets

**Rails side**

- Six bugs fixed in a single pass:
  - Removed ISBN from book search results (debug field left in)
  - Reading log page count: added `greater_than: 0, allow_nil: true`
    validation; hide page count on entry display if nil or zero
  - Cycle close actions: added `data-turbo-confirm` to both close buttons
    with explanatory copy so users understand the consequence before confirming
  - Fixed literal ERB tags visible on auth screens; added SVG logo to
    auth layout
  - Mobile web responsive sweep—dashboard, club detail, and auth
    screens audited and fixed at narrow viewports
  - Email encryption: added `encrypts :email_address, deterministic: true`
    to User model; deterministic required for sign-in lookup. ADR written.

**What was skipped or deferred**

- Barcode scan (#8)—demoted to tier 2; carrying to tomorrow
- Mobile write actions (nominate, vote, log note)—requires new Rails
  API endpoints; scoped as Phase 1 roadmap item, not this week
- SwiftUI/ExpoUI design pass—deferred to post-write-actions
- System tests (#42), Sentry (#51)—still carried

**Surprises and deviations**

- NativeWind incompatible with Metro 0.83.6—replaced with Uniwind
  mid-session on Day 8; no downstream impact due to identical API
- Design tokens package required more setup than anticipated—GitHub
  Packages auth in Dockerfile needed a BuildKit secret mount to satisfy
  the Dockerfile linter (`SecretsUsedInArgOrEnv`)
- Token refresh interceptor required careful setup to avoid stacking
  on hot reload—guarded with `interceptorsSetUp` flag
- Fly deploy was broken by the design tokens package not being installed
  in the Docker build—fixed with Node/npm install step and BuildKit secret

**Open questions into Day 10**

- Barcode scan (#8)
- Final JOURNAL and decisions pass (#54)
- README cross-linking, demo URLs, screenshots (#53)
- TODO sweep across both repos (#55)
- EAS preview build and shareable link (#10)
