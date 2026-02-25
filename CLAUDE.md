# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

fmog (Feed MogMog) is a Ruby CLI feed aggregator for subscribing to, fetching, and reading RSS/Atom feeds from the terminal. Built as a gem with Thor for CLI, SQLite for storage, and the `rss` stdlib for parsing.

## Commands

```bash
# Install dependencies
bundle install

# Run full CI (tests + type checking) — this is the default rake task
bundle exec rake ci

# Run tests only
bundle exec rake test

# Run a single test file
bundle exec ruby test/test_feed.rb

# Run a single test method
bundle exec ruby test/test_feed.rb --name test_add_returns_id

# Run Steep type checker
bundle exec rake steep

# Run the CLI
bundle exec fmog feed add URL
bundle exec fmog feed list
bundle exec fmog item list --unread
```

## Architecture

All domain logic lives in `lib/fmog/` as Ruby modules (not classes):

- **`cli.rb`** — Thor-based CLI with two subcommand groups: `FeedCLI` (feed add/list/remove/fetch) and `ItemCLI` (item list/show/read/unread). Outputs as ASCII tables when connected to a TTY, JSON Lines when piped.
- **`db.rb`** — Singleton SQLite connection to `~/.local/share/fmog/fmog.db` with idempotent schema migration. Uses `DB.reset!` in tests to swap in `:memory:` databases.
- **`feed.rb`** — Feed CRUD operations (add, list, find, remove, update_title, touch_fetched).
- **`item.rb`** — Item operations with `upsert` using `INSERT ... ON CONFLICT` on the `(feed_id, guid)` composite unique key. Supports filtered listing by feed, unread status, and limit.
- **`fetcher.rb`** — Fetches and parses RSS 2.0 and Atom feeds. Private `extract_*` methods handle format differences between RSS and Atom entries.
- **`exe/fmog`** — Entry point that calls `Fmog::CLI.start(ARGV)`.

## Type System

RBS type definitions in `sig/` are checked by Steep (configured in `Steepfile` with lenient diagnostics). External library stubs for rss, sqlite3, thor, and terminal-table are in `sig/*.rbs`. Type checking runs as part of CI.

## Testing

Tests use Minitest. `test/test_helper.rb` provides `FmogTestCase` base class that sets up an in-memory SQLite database per test and a `run_cli` helper for invoking Thor commands and capturing output. `test_fetcher.rb` uses `URI.stub` to mock HTTP requests with embedded RSS/Atom sample data.
