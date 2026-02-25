# frozen_string_literal: true

require_relative "test_helper"

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

SAMPLE_ATOM = <<~XML unless defined?(SAMPLE_ATOM)
  <?xml version="1.0" encoding="UTF-8"?>
  <feed xmlns="http://www.w3.org/2005/Atom">
    <title>Atom Test Feed</title>
    <entry>
      <title>Atom Article 1</title>
      <link href="https://example.com/atom/1"/>
      <id>atom-guid-1</id>
      <content type="html">Atom body 1</content>
      <updated>2024-01-01T00:00:00Z</updated>
    </entry>
  </feed>
XML

class TestFetcher < FmogTestCase
  def setup
    super
    @feed_id = Fmog::Feed.add("https://example.com/feed.xml")
  end

  def test_fetch_rss_feed
    URI.stub(:open, ->(*_) { StringIO.new(SAMPLE_RSS) }) do
      count = Fmog::Fetcher.fetch(@feed_id)
      assert_equal 2, count
    end

    items = Fmog::Item.list(feed_id: @feed_id)
    assert_equal 2, items.length

    feed = Fmog::Feed.find(@feed_id)
    assert_equal "Test Feed", feed["title"]
    refute_nil feed["last_fetched_at"]
  end

  def test_fetch_atom_feed
    atom_id = Fmog::Feed.add("https://example.com/atom.xml")
    URI.stub(:open, ->(*_) { StringIO.new(SAMPLE_ATOM) }) do
      count = Fmog::Fetcher.fetch(atom_id)
      assert_equal 1, count
    end

    items = Fmog::Item.list(feed_id: atom_id)
    assert_equal 1, items.length
    assert_equal "Atom Article 1", items[0]["title"]
  end

  def test_fetch_updates_feed_title
    URI.stub(:open, ->(*_) { StringIO.new(SAMPLE_RSS) }) do
      Fmog::Fetcher.fetch(@feed_id)
    end
    assert_equal "Test Feed", Fmog::Feed.find(@feed_id)["title"]
  end

  def test_fetch_nonexistent_feed_raises
    assert_raises(RuntimeError, "Feed not found: 999") do
      Fmog::Fetcher.fetch(999)
    end
  end

  def test_fetch_is_idempotent
    URI.stub(:open, ->(*_) { StringIO.new(SAMPLE_RSS) }) do
      Fmog::Fetcher.fetch(@feed_id)
      Fmog::Fetcher.fetch(@feed_id)
    end
    items = Fmog::Item.list(feed_id: @feed_id)
    assert_equal 2, items.length
  end

  def test_fetch_all
    Fmog::Feed.add("https://example.com/feed2.xml")
    URI.stub(:open, ->(*_) { StringIO.new(SAMPLE_RSS) }) do
      results = Fmog::Fetcher.fetch_all
      assert_equal 2, results.length
      results.each { |r| assert_equal 2, r[:count] }
    end
  end

  def test_fetch_stores_item_fields
    URI.stub(:open, ->(*_) { StringIO.new(SAMPLE_RSS) }) do
      Fmog::Fetcher.fetch(@feed_id)
    end

    items = Fmog::Item.list(feed_id: @feed_id)
    article1 = items.find { |i| i["guid"] == "guid-1" }
    assert_equal "Article 1", article1["title"]
    assert_equal "https://example.com/1", article1["url"]
    assert_equal "Body of article 1", article1["body"]
    refute_nil article1["published_at"]
  end
end
