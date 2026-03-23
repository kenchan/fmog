# frozen_string_literal: true

require_relative "test_helper"
require "tempfile"

SAMPLE_OPML = <<~XML
  <?xml version="1.0" encoding="UTF-8"?>
  <opml version="2.0">
    <head><title>My Feeds</title></head>
    <body>
      <outline text="Tech" title="Tech">
        <outline text="Ruby" title="Ruby" type="rss"
          xmlUrl="https://example.com/ruby.xml" htmlUrl="https://example.com/ruby"/>
        <outline text="Rails" title="Rails" type="rss"
          xmlUrl="https://example.com/rails.xml" htmlUrl="https://example.com/rails"/>
      </outline>
      <outline text="Flat" title="Flat" type="rss"
        xmlUrl="https://example.com/flat.xml" htmlUrl="https://example.com/flat"/>
    </body>
  </opml>
XML

class TestOpmlImporter < FmogTestCase
  def write_opml(content)
    f = Tempfile.new(["test", ".opml"])
    f.write(content)
    f.flush
    f
  end

  def test_imports_all_urls
    f = write_opml(SAMPLE_OPML)
    result = Fmog::Opml::Importer.import(f.path)
    assert_equal 3, result.added
    assert_equal 0, result.skipped
    assert_empty result.errors
    assert_equal 3, Fmog::Feed.list.length
  ensure
    f&.close!
  end

  def test_skips_duplicates
    Fmog::Feed.add("https://example.com/ruby.xml")
    f = write_opml(SAMPLE_OPML)
    result = Fmog::Opml::Importer.import(f.path)
    assert_equal 2, result.added
    assert_equal 1, result.skipped
    assert_empty result.errors
  ensure
    f&.close!
  end

  def test_handles_nested_outlines
    opml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <opml version="2.0">
        <body>
          <outline text="Level1">
            <outline text="Level2">
              <outline text="Deep" type="rss" xmlUrl="https://example.com/deep.xml"/>
            </outline>
          </outline>
        </body>
      </opml>
    XML
    f = write_opml(opml)
    result = Fmog::Opml::Importer.import(f.path)
    assert_equal 1, result.added
  ensure
    f&.close!
  end

  def test_raises_on_missing_file
    assert_raises(RuntimeError) { Fmog::Opml::Importer.import("/nonexistent/file.opml") }
  end

  def test_raises_on_invalid_xml
    f = write_opml("<not valid xml<<<")
    assert_raises(RuntimeError) { Fmog::Opml::Importer.import(f.path) }
  ensure
    f&.close!
  end

  def test_skips_outlines_without_xml_url
    opml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <opml version="2.0">
        <body>
          <outline text="Category" title="Category"/>
          <outline text="Feed" type="rss" xmlUrl="https://example.com/feed.xml"/>
        </body>
      </opml>
    XML
    f = write_opml(opml)
    result = Fmog::Opml::Importer.import(f.path)
    assert_equal 1, result.added
  ensure
    f&.close!
  end
end

class TestFeedCLIImport < FmogTestCase
  def write_opml(content)
    f = Tempfile.new(["test", ".opml"])
    f.write(content)
    f.flush
    f
  end

  def test_import_outputs_json
    f = write_opml(SAMPLE_OPML)
    out, = run_cli(Fmog::FeedCLI, "import", f.path)
    result = JSON.parse(out.strip)
    assert_equal 3, result["added"]
    assert_equal 0, result["skipped"]
    assert_empty result["errors"]
  ensure
    f&.close!
  end

  def test_import_tty_shows_summary
    f = write_opml(SAMPLE_OPML)
    out = run_tty_cli(Fmog::FeedCLI, "import", f.path)
    assert_match(/3 added/, out)
    assert_match(/0 error/, out)
  ensure
    f&.close!
  end

  def test_import_nonexistent_file_shows_error
    _, err = run_cli(Fmog::FeedCLI, "import", "/nonexistent/file.opml")
    assert_match(/Error/, err)
  end
end
