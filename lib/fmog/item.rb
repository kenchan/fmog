# frozen_string_literal: true

module Fmog
  module Item
    COLUMNS = "id, feed_id, guid, title, url, body, published_at, read_at, created_at"

    def self.upsert(feed_id:, guid:, title:, url:, body:, published_at:)
      DB.connection.execute(<<~SQL, [feed_id, guid, title, url, body, published_at])
        INSERT INTO items (feed_id, guid, title, url, body, published_at)
        VALUES (?, ?, ?, ?, ?, ?)
        ON CONFLICT(feed_id, guid) DO UPDATE SET
          title = excluded.title,
          url = excluded.url,
          body = excluded.body,
          published_at = excluded.published_at
      SQL
    end

    def self.list(feed_id: nil, unread: false, limit: 50)
      conditions = []
      params = []

      if feed_id
        conditions << "feed_id = ?"
        params << feed_id
      end

      if unread
        conditions << "read_at IS NULL"
      end

      where = conditions.empty? ? "" : "WHERE #{conditions.join(" AND ")}"

      DB.connection.execute(
        "SELECT #{COLUMNS} FROM items #{where} ORDER BY published_at DESC, id DESC LIMIT ?",
        params + [limit]
      )
    end

    def self.find(id)
      DB.connection.execute("SELECT #{COLUMNS} FROM items WHERE id = ?", [id]).first
    end

    def self.mark_read(id)
      DB.connection.execute("UPDATE items SET read_at = datetime('now') WHERE id = ?", [id])
      DB.connection.changes
    end

    def self.mark_unread(id)
      DB.connection.execute("UPDATE items SET read_at = NULL WHERE id = ?", [id])
      DB.connection.changes
    end
  end
end
