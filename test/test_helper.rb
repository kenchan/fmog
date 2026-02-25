# frozen_string_literal: true

require "minitest/autorun"
require "stringio"
require "sqlite3"

require_relative "../lib/fmog"

class FmogTestCase < Minitest::Test
  def setup
    Fmog::DB.reset!
    db = SQLite3::Database.new(":memory:")
    db.results_as_hash = true
    db.execute("PRAGMA foreign_keys = ON")
    Fmog::DB.migrate(db)
    Fmog::DB.instance_variable_set(:@connection, db)
  end

  def teardown
    Fmog::DB.reset!
  end

  # Run a Thor CLI command and capture output, swallowing SystemExit
  def run_cli(klass, *args)
    capture_io do
      klass.start(args.map(&:to_s))
    rescue SystemExit
      # swallow exit calls from error handlers
    end
  end
end
