# NextChapter

A book club web app. Groups of readers form a club, nominate books, vote on
what to read next, and track what they've read together.

Built as a portfolio project across nine focused days to demonstrate tightly
scoped, modern Rails 8 development: Hotwire for a server-rendered UI,
Solid Queue for background jobs, Active Storage for file handling, and an
Expo / React Native companion app for mobile (in progress).

**Status:** Complete (for now).

Full club lifecycle, design system, REST API, and Expo/React Native companion app built across nine days.

See [JOURNAL](docs/JOURNAL.md) for historic daily progress logs.

See [ROADMAP](docs/ROADMAP.md) for future plans.

[![CI](https://github.com/stevebutler2210/nextchapter/actions/workflows/ci.yml/badge.svg)](https://github.com/stevebutler2210/nextchapter/actions/workflows/ci.yml)
![Ruby](https://img.shields.io/badge/ruby-3.4.9-red)
![Rails](https://img.shields.io/badge/rails-8.1.3-red)

---

## Live demo

[nextchapter.fly.dev](https://nextchapter.fly.dev)

![NextChapter screenshot](docs/readme_assets/banner.png)

---

## Project docs

These are worth reading before the code—they show the thinking behind the
project as much as the implementation.

| Doc                             | Purpose                                                                                                          |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| [PLAN.md](docs/PLAN.md)         | Day-0 plan. Committed at the start and not rewritten—the gap between plan and shipped is part of the story.      |
| [JOURNAL.md](docs/JOURNAL.md)   | Daily log. What shipped, what changed, what was surprising.                                                      |
| [WORKFLOW.md](docs/WORKFLOW.md) | Conventions, branching, commit style, ticket format, deployment.                                                 |
| [decisions/](docs/decisions/)   | Architecture Decision Records. One file per meaningful choice, covering context, alternatives, and consequences. |

---

## Stack

**Web (`nextchapter`)**

- Ruby 3.4.9, Rails 8.1.3
- SQLite (development and production via Fly.io persistent volume)
- Hotwire (Turbo + Stimulus)—server-rendered UI, no client-side SPA
- Tailwind CSS v4 with design tokens shared via [`@stevebutler2210/nextchapter-design-tokens`](https://github.com/stevebutler2210/nextchapter-design-tokens)
- Solid Queue for background jobs
- Solid Cache for caching
- Solid Cable for Action Cable
- Active Storage for book cover images
- Active Record Encryption for reading log notes
- Faraday for Google Books API integration
- Minitest, GitHub Actions CI
- Deployed to Fly.io

**Mobile (`nextchapter-mobile`)** _(in progress, Day 8–9)_

- Expo SDK, React Native, TypeScript
- Expo Router for navigation
- Uniwind (drop-in NativeWind alternative) with shared design tokens
- JWT auth against the Rails API
- ISBN barcode scanning to add books

---

## Local setup

### Prerequisites

- Ruby 3.4.9 (`rbenv` or `asdf` recommended)
- Bundler
- Node 20
- A Google Books API key ([get one here](https://console.cloud.google.com/apis/library/books.googleapis.com))
- A GitHub PAT scoped to `read:packages` (required to install the private design tokens package)

### Steps

```bash
git clone https://github.com/stevebutler2210/nextchapter.git
cd nextchapter
bin/setup
```

> **Note:** `db:reset` does not load `cable_schema.rb` automatically. After a reset, if live features (vote tallies, nomination broadcasts) aren't working, load it manually: `bin/rails runner 'load Rails.root.join("db/cable_schema.rb")'`

Add your Google Books API key to Rails credentials:

```bash
bin/rails credentials:edit
```

Add the following:

```yaml
google_books_api_key: YOUR_KEY_HERE
```

Add your GitHub PAT to your shell profile (`.zshrc`, `.bashrc`, etc.):

```bash
export PACKAGES_TOKEN=your_github_pat
```

Then install npm dependencies:

```bash
npm install
```

Start the app (web + background worker):

```bash
bin/dev
```

Visit [http://localhost:3000](http://localhost:3000).

---

## Running tests

```bash
bin/rails test
```

CI runs on every pull request via GitHub Actions (docs-only PRs are ignored).

---

## On AI assistance

This project was built with AI assistance—Claude for planning, scoping, and
decision rubber-ducking; Copilot for day-to-day code suggestions. The thinking
was collaborative; the judgment calls are mine.

Every decision in [docs/decisions/](docs/decisions/) is one I understood,
agreed with after weighing alternatives, and can speak to under questioning.
