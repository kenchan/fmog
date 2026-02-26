# Changelog

All notable changes to this project will be documented in this file.

## [v0.1.0](https://github.com/kenchan/fmog/commits/v/v0.1.0) - 2026-02-26
- fix: remove redundant item deletion in Feed#remove by @kenchan in https://github.com/kenchan/fmog/pull/2
- refactor: redesign Fetcher as a class with private instance methods by @kenchan in https://github.com/kenchan/fmog/pull/3
- refactor: extract BaseCLI to remove duplicated tty?/output_single by @kenchan in https://github.com/kenchan/fmog/pull/4
- feat: use xdg gem for XDG-compliant DB path by @kenchan in https://github.com/kenchan/fmog/pull/5
- docs: fix Fetcher architecture note, update DB path description, add contributing guidelines by @kenchan in https://github.com/kenchan/fmog/pull/6
- chore: prepare gemspec and repo for RubyGems.org release (closes #1) by @kenchan in https://github.com/kenchan/fmog/pull/7
- ci: add tagpr and RubyGems Trusted Publishing workflow by @kenchan in https://github.com/kenchan/fmog/pull/8

## [0.1.0] - 2025-02-26

### Added
- Initial release
- `fmog feed add/list/remove/fetch` commands
- `fmog item list/show/read/unread` commands
- SQLite storage with XDG Base Directory Specification support
- RSS 2.0 and Atom feed support
- TTY-aware output (ASCII table for humans, JSON Lines for pipes)
- RBS type definitions
