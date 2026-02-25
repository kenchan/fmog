# frozen_string_literal: true

module Fmog
  module Feed
    def self.add(url)
      db = DB.connection
      db.execute("INSERT INTO feeds (url) VALUES (?)", [url])
      db.last_insert_row_id
    end

    def self.list
      DB.connection.execute("SELECT id, url, title, last_fetched_at, created_at FROM feeds ORDER BY id")
    end

    def self.find(id)
      DB.connection.execute("SELECT id, url, title, last_fetched_at, created_at FROM feeds WHERE id = ?", [id]).first
    end

    def self.remove(id)
      db = DB.connection
      db.execute("DELETE FROM feeds WHERE id = ?", [id])
      db.changes
    end

    def self.update_title(id, title)
      DB.connection.execute("UPDATE feeds SET title = ? WHERE id = ?", [title, id])
    end

    def self.touch_fetched(id)
      DB.connection.execute("UPDATE feeds SET last_fetched_at = datetime('now') WHERE id = ?", [id])
    end
  end
end
