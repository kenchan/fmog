# frozen_string_literal: true

require_relative "test_helper"
require "json"

SAMPLE_RSS = <<~XML unless defined?(SAMPLE_RSS)
  <?xml version="1.0" encoding="UTF-8"?>
  <rss version="2.0">
    <channel>
      <title>Test Feed</title>
      <link>https://example.com</link>
      <item>
        <title>Article 1</title>
        <link>https://example.com/1</link>
        <guid>guid-1</guid>
        <description>Body of article 1</description>
        <pubDate>Mon, 01 Jan 2024 00:00:00 GMT</pubDate>
      </item>
      <item>
        <title>Article 2</title>
        <link>https://example.com/2</link>
        <guid>guid-2</guid>
        <description>Body of article 2</description>
      </item>
    </channel>
  </rss>
XML

class TestFeedCLI < FmogTestCase
  def test_add_outputs_json
    out, = run_cli(Fmog::FeedCLI, "add", "https://example.com/feed.xml")
    result = JSON.parse(out.strip)
    assert_equal 1, result["id"]
    assert_equal "https://example.com/feed.xml", result["url"]
  end

  def test_add_duplicate_shows_error
    Fmog::Feed.add("https://example.com/feed.xml")
    _, err = run_cli(Fmog::FeedCLI, "add", "https://example.com/feed.xml")
    assert_match(/already exists/, err)
  end

  def test_list_outputs_json_lines
    Fmog::Feed.add("https://example.com/feed1.xml")
    Fmog::Feed.add("https://example.com/feed2.xml")
    out, = run_cli(Fmog::FeedCLI, "list")
    lines = out.strip.split("\n")
    assert_equal 2, lines.length
    lines.each { |l| JSON.parse(l) } # should not raise
  end

  def test_list_empty
    out, = run_cli(Fmog::FeedCLI, "list")
    assert_empty out.strip
  end

  def test_list_tty_renders_table
    Fmog::Feed.add("https://example.com/feed.xml")
    out = run_tty_cli(Fmog::FeedCLI, "list")
    assert_match(/ID/, out)
    assert_match(/URL/, out)
  end

  def test_remove_outputs_json
    id = Fmog::Feed.add("https://example.com/feed.xml")
    out, = run_cli(Fmog::FeedCLI, "remove", id.to_s)
    result = JSON.parse(out.strip)
    assert_equal id, result["id"]
  end

  def test_remove_nonexistent_shows_error
    _, err = run_cli(Fmog::FeedCLI, "remove", "999")
    assert_match(/not found/, err)
  end

  def test_fetch_with_stub
    id = Fmog::Feed.add("https://example.com/feed.xml")
    URI.stub(:open, ->(*_) { StringIO.new(SAMPLE_RSS) }) do
      out, = run_cli(Fmog::FeedCLI, "fetch", id.to_s)
      result = JSON.parse(out.strip)
      assert_equal id, result["id"]
      assert_equal 2, result["count"]
    end
  end

  def test_fetch_all_with_stub
    id1 = Fmog::Feed.add("https://example.com/feed1.xml")
    id2 = Fmog::Feed.add("https://example.com/feed2.xml")
    URI.stub(:open, ->(*_) { StringIO.new(SAMPLE_RSS) }) do
      out, = run_cli(Fmog::FeedCLI, "fetch")
      lines = out.strip.split("\n")
      assert_equal 2, lines.length

      results = lines.map { |l| JSON.parse(l) }
      results.each do |r|
        assert_includes [id1, id2], r["id"]
        assert_includes ["https://example.com/feed1.xml", "https://example.com/feed2.xml"], r["url"]
        assert_equal 2, r["count"]
      end
    end
  end
end

class TestItemCLI < FmogTestCase
  def setup
    super
    @feed_id = Fmog::Feed.add("https://example.com/feed.xml")
    Fmog::Item.upsert(
      feed_id: @feed_id, guid: "g1", title: "Test Item",
      url: "http://example.com/1", body: "Content here", published_at: "2024-01-01 00:00:00"
    )
    @item_id = Fmog::Item.list.first["id"]
  end

  def test_list_outputs_json_lines
    out, = run_cli(Fmog::ItemCLI, "list")
    lines = out.strip.split("\n")
    assert_equal 1, lines.length
    result = JSON.parse(lines[0])
    assert_equal "Test Item", result["title"]
  end

  def test_list_tty_renders_table
    out = run_tty_cli(Fmog::ItemCLI, "list")
    assert_match(/ID/, out)
    assert_match(/Title/, out)
  end

  def test_show_outputs_json
    out, = run_cli(Fmog::ItemCLI, "show", @item_id.to_s)
    result = JSON.parse(out.strip)
    assert_equal "Test Item", result["title"]
    assert_equal "Content here", result["body"]
  end

  def test_show_nonexistent_shows_error
    _, err = run_cli(Fmog::ItemCLI, "show", "999")
    assert_match(/not found/, err)
  end

  def test_read_marks_item
    out, = run_cli(Fmog::ItemCLI, "read", @item_id.to_s)
    result = JSON.parse(out.strip)
    assert_equal true, result["read"]
    refute_nil Fmog::Item.find(@item_id)["read_at"]
  end

  def test_unread_marks_item
    Fmog::Item.mark_read(@item_id)
    out, = run_cli(Fmog::ItemCLI, "unread", @item_id.to_s)
    result = JSON.parse(out.strip)
    assert_equal false, result["read"]
    assert_nil Fmog::Item.find(@item_id)["read_at"]
  end
end
