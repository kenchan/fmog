# frozen_string_literal: true

require "sqlite3"
require "fileutils"
require "xdg"

module Fmog
  module DB
    DB_DIR = XDG.new.data_home.join("fmog").to_s
    DB_PATH = File.join(DB_DIR, "fmog.db")

    def self.connection
      @connection ||= begin
        FileUtils.mkdir_p(DB_DIR)
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true
        db.execute("PRAGMA foreign_keys = ON")
        migrate(db)
        db
      end
    end

    def self.migrate(db)
      db.execute(<<~SQL)
        CREATE TABLE IF NOT EXISTS feeds (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          url TEXT NOT NULL UNIQUE,
          title TEXT,
          last_fetched_at DATETIME,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      SQL

      db.execute(<<~SQL)
        CREATE TABLE IF NOT EXISTS items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          feed_id INTEGER NOT NULL REFERENCES feeds(id) ON DELETE CASCADE,
          guid TEXT NOT NULL,
          title TEXT,
          url TEXT,
          body TEXT,
          published_at DATETIME,
          read_at DATETIME,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(feed_id, guid)
        )
      SQL
    end

    def self.reset!
      @connection = nil
    end
  end
end
