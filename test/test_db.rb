# frozen_string_literal: true

require_relative "test_helper"

class TestDB < FmogTestCase
  def test_migration_creates_feeds_table
    db = Fmog::DB.connection
    tables = db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='feeds'")
    assert_equal 1, tables.length
  end

  def test_migration_creates_items_table
    db = Fmog::DB.connection
    tables = db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='items'")
    assert_equal 1, tables.length
  end

  def test_migration_is_idempotent
    db = Fmog::DB.connection
    Fmog::DB.migrate(db)
    tables = db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='feeds'")
    assert_equal 1, tables.length
  end

  def test_foreign_keys_enabled
    db = Fmog::DB.connection
    result = db.execute("PRAGMA foreign_keys")
    assert_equal 1, result.first["foreign_keys"]
  end

  def test_results_as_hash
    db = Fmog::DB.connection
    db.execute("INSERT INTO feeds (url) VALUES ('https://example.com/feed.xml')")
    row = db.execute("SELECT * FROM feeds").first
    assert_kind_of Hash, row
    assert_equal "https://example.com/feed.xml", row["url"]
  end

  def test_reset_clears_connection
    Fmog::DB.reset!
    assert_nil Fmog::DB.instance_variable_get(:@connection)
  end
end
