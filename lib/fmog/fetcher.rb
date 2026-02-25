# frozen_string_literal: true

require "rss"
require "open-uri"

module Fmog
  class Fetcher
    def self.fetch(feed_id)
      new(feed_id).call
    end

    def self.fetch_all
      Feed.list.map do |feed|
        count = fetch(feed["id"])
        { id: feed["id"], url: feed["url"], count: count }
      end
    end

    def initialize(feed_id)
      @feed_id = feed_id
    end

    def call
      feed = Feed.find(@feed_id)
      raise "Feed not found: #{@feed_id}" unless feed

      content = URI.open(feed["url"]).read
      parsed = RSS::Parser.parse(content, false)
      raise "Failed to parse feed: #{feed["url"]}" unless parsed

      title = extract_feed_title(parsed)
      Feed.update_title(@feed_id, title) if title

      count = 0
      items = parsed.items || []
      items.each do |entry|
        guid = extract_guid(entry)
        next unless guid

        Item.upsert(
          feed_id: @feed_id,
          guid: guid,
          title: extract_title(entry),
          url: extract_url(entry),
          body: extract_body(entry),
          published_at: extract_date(entry)&.strftime("%Y-%m-%d %H:%M:%S")
        )
        count += 1
      end

      Feed.touch_fetched(@feed_id)
      count
    end

    private

    def extract_feed_title(parsed)
      if parsed.respond_to?(:channel) && parsed.channel
        parsed.channel.title
      elsif parsed.title.respond_to?(:content)
        parsed.title.content
      end
    end

    def extract_guid(entry)
      # RSS 2.0
      return entry.guid&.content if entry.respond_to?(:guid) && entry.guid
      # Atom
      return entry.id&.content if entry.respond_to?(:id) && entry.id.respond_to?(:content)
      # fallback
      extract_url(entry)
    end

    def extract_title(entry)
      return entry.title.content if entry.title.respond_to?(:content)
      entry.title.to_s
    end

    def extract_url(entry)
      # Atom
      if entry.respond_to?(:link) && entry.link.respond_to?(:href)
        return entry.link.href
      end
      # RSS 2.0
      return entry.link if entry.respond_to?(:link)
      nil
    end

    def extract_body(entry)
      # Atom content
      if entry.respond_to?(:content) && entry.content
        return entry.content.content if entry.content.respond_to?(:content)
      end
      # RSS description
      if entry.respond_to?(:description)
        return entry.description
      end
      nil
    end

    def extract_date(entry)
      # Atom
      return entry.updated&.content if entry.respond_to?(:updated) && entry.updated
      return entry.published&.content if entry.respond_to?(:published) && entry.published
      # RSS 2.0
      return entry.date if entry.respond_to?(:date)
      return entry.pubDate if entry.respond_to?(:pubDate)
      nil
    end
  end
end
