# fmog (Feed MogMog)

A CLI feed aggregator written in Ruby. Subscribe to and read RSS/Atom feeds from your terminal.

## Installation

```bash
bundle install
```

## Usage

### Feed Management

```bash
# Add a feed
bundle exec fmog feed add https://example.com/feed.xml

# List all feeds
bundle exec fmog feed list

# Fetch all feeds
bundle exec fmog feed fetch

# Fetch a specific feed
bundle exec fmog feed fetch 1

# Remove a feed
bundle exec fmog feed remove 1
```

### Item (Article) Management

```bash
# List items
bundle exec fmog item list

# Show only unread items
bundle exec fmog item list --unread

# Filter items by feed
bundle exec fmog item list --feed 1

# Limit the number of items
bundle exec fmog item list --limit 10

# Show item details
bundle exec fmog item show 1

# Mark as read
bundle exec fmog item read 1

# Mark as unread
bundle exec fmog item unread 1
```

## Output Format

- **Terminal (TTY)**: Human-readable table format
- **Pipe/Redirect**: JSON Lines (one JSON object per line)

```bash
# Pipe JSON Lines to other commands
bundle exec fmog item list --unread | jq '.title'
```

## Data Storage

`~/.local/share/fmog/fmog.db` (SQLite)

## Development

```bash
# Run tests
bundle exec rake test

# Run type check
bundle exec rake steep

# Run full CI (tests + type check)
bundle exec rake ci
```
