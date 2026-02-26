# frozen_string_literal: true

require "thor"
require "json"
require "terminal-table"

module Fmog
  class BaseCLI < Thor
    private

    def tty?
      $stdout.tty?
    end

    def output_single(hash, message)
      if tty?
        puts message
      else
        puts JSON.generate(hash)
      end
    end
  end

  class FeedCLI < BaseCLI
    namespace "feed"

    desc "add URL", "Add a feed"
    def add(url)
      id = Feed.add(url)
      output_single({ id: id, url: url }, "Added feed ##{id}: #{url}")
    rescue SQLite3::ConstraintException
      $stderr.puts "Error: Feed already exists: #{url}"
      exit 1
    end

    desc "list", "List feeds"
    def list
      feeds = Feed.list
      if tty?
        if feeds.empty?
          puts "No feeds."
          return
        end
        table = ::Terminal::Table.new(
          headings: ["ID", "Title", "URL", "Last Fetched"],
          rows: feeds.map { |f| [f["id"], f["title"] || "-", f["url"], f["last_fetched_at"] || "-"] }
        )
        puts table
      else
        feeds.each { |f| puts JSON.generate(f) }
      end
    end

    desc "remove ID", "Remove a feed"
    def remove(id)
      count = Feed.remove(id.to_i)
      if count > 0
        output_single({ id: id.to_i }, "Removed feed ##{id}")
      else
        $stderr.puts "Error: Feed not found: #{id}"
        exit 1
      end
    end

    desc "fetch [ID]", "Fetch feed(s)"
    def fetch(id = nil)
      if id
        count = Fetcher.fetch(id.to_i)
        output_single({ id: id.to_i, count: count }, "Fetched #{count} items from feed ##{id}")
      else
        results = Fetcher.fetch_all
        if tty?
          results.each { |r| puts "Feed ##{r[:id]} (#{r[:url]}): #{r[:count]} items" }
        else
          results.each { |r| puts JSON.generate(r) }
        end
      end
    rescue => e
      $stderr.puts "Error: #{e.message}"
      exit 1
    end

  end

  class ItemCLI < BaseCLI
    namespace "item"

    desc "list", "List items"
    option :feed, type: :numeric, desc: "Filter by feed ID"
    option :unread, type: :boolean, default: false, desc: "Show only unread items"
    option :limit, type: :numeric, default: 50, desc: "Max items to show"
    def list
      items = Item.list(feed_id: options[:feed], unread: options[:unread], limit: options[:limit])
      if tty?
        if items.empty?
          puts "No items."
          return
        end
        table = ::Terminal::Table.new(
          headings: ["ID", "Feed", "Title", "Published", "Read"],
          rows: items.map { |i|
            read_mark = i["read_at"] ? "Y" : ""
            title = (i["title"] || "").slice(0, 60)
            [i["id"], i["feed_id"], title, i["published_at"] || "-", read_mark]
          }
        )
        puts table
      else
        items.each { |i| puts JSON.generate(i) }
      end
    end

    desc "show ID", "Show item details"
    def show(id)
      item = Item.find(id.to_i)
      unless item
        $stderr.puts "Error: Item not found: #{id}"
        exit 1
      end

      if tty?
        puts "ID:        #{item["id"]}"
        puts "Feed:      #{item["feed_id"]}"
        puts "Title:     #{item["title"]}"
        puts "URL:       #{item["url"]}"
        puts "Published: #{item["published_at"]}"
        puts "Read:      #{item["read_at"] || "no"}"
        puts "---"
        puts item["body"] if item["body"]
      else
        puts JSON.generate(item)
      end
    end

    desc "read ID", "Mark item as read"
    def read(id)
      count = Item.mark_read(id.to_i)
      if count > 0
        output_single({ id: id.to_i, read: true }, "Marked item ##{id} as read")
      else
        $stderr.puts "Error: Item not found: #{id}"
        exit 1
      end
    end

    desc "unread ID", "Mark item as unread"
    def unread(id)
      count = Item.mark_unread(id.to_i)
      if count > 0
        output_single({ id: id.to_i, read: false }, "Marked item ##{id} as unread")
      else
        $stderr.puts "Error: Item not found: #{id}"
        exit 1
      end
    end

  end

  class CLI < Thor
    desc "feed SUBCOMMAND", "Manage feeds"
    subcommand "feed", FeedCLI

    desc "item SUBCOMMAND", "Manage items"
    subcommand "item", ItemCLI
  end
end
