# fmog (Feed MogMog)

A CLI feed aggregator written in Ruby. Subscribe to and read RSS/Atom feeds from your terminal.

## Installation

```bash
gem install fmog
```

Or try it without installing (like npx):

```bash
gem exec fmog feed list
```

## Usage

### Feed Management

```bash
# Add a feed
fmog feed add https://example.com/feed.xml

# List all feeds
fmog feed list

# Fetch all feeds
fmog feed fetch

# Fetch a specific feed
fmog feed fetch 1

# Remove a feed
fmog feed remove 1
```

### Item (Article) Management

```bash
# List items
fmog item list

# Show only unread items
fmog item list --unread

# Filter items by feed
fmog item list --feed 1

# Limit the number of items
fmog item list --limit 10

# Show item details
fmog item show 1

# Mark as read
fmog item read 1

# Mark as unread
fmog item unread 1
```

## Output Format

- **Terminal (TTY)**: Human-readable table format
- **Pipe/Redirect**: JSON Lines (one JSON object per line)

```bash
# Pipe JSON Lines to other commands
fmog item list --unread | jq '.title'
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
