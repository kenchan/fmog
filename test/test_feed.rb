# frozen_string_literal: true

require_relative "test_helper"

class TestFeed < FmogTestCase
  def test_add_returns_id
    id = Fmog::Feed.add("https://example.com/feed.xml")
    assert_equal 1, id
  end

  def test_add_duplicate_raises
    Fmog::Feed.add("https://example.com/feed.xml")
    assert_raises(SQLite3::ConstraintException) do
      Fmog::Feed.add("https://example.com/feed.xml")
    end
  end

  def test_list_empty
    assert_empty Fmog::Feed.list
  end

  def test_list_returns_feeds_ordered_by_id
    Fmog::Feed.add("https://example.com/feed1.xml")
    Fmog::Feed.add("https://example.com/feed2.xml")
    feeds = Fmog::Feed.list
    assert_equal 2, feeds.length
    assert_equal "https://example.com/feed1.xml", feeds[0]["url"]
    assert_equal "https://example.com/feed2.xml", feeds[1]["url"]
  end

  def test_find_existing
    id = Fmog::Feed.add("https://example.com/feed.xml")
    feed = Fmog::Feed.find(id)
    assert_equal id, feed["id"]
    assert_equal "https://example.com/feed.xml", feed["url"]
    assert_nil feed["title"]
  end

  def test_find_nonexistent
    assert_nil Fmog::Feed.find(999)
  end

  def test_remove_existing
    id = Fmog::Feed.add("https://example.com/feed.xml")
    count = Fmog::Feed.remove(id)
    assert_equal 1, count
    assert_nil Fmog::Feed.find(id)
  end

  def test_remove_nonexistent
    count = Fmog::Feed.remove(999)
    assert_equal 0, count
  end

  def test_remove_cascades_items
    id = Fmog::Feed.add("https://example.com/feed.xml")
    Fmog::Item.upsert(feed_id: id, guid: "g1", title: "T", url: "http://x", body: "B", published_at: nil)
    Fmog::Feed.remove(id)
    assert_empty Fmog::Item.list
  end

  def test_update_title
    id = Fmog::Feed.add("https://example.com/feed.xml")
    Fmog::Feed.update_title(id, "My Feed")
    feed = Fmog::Feed.find(id)
    assert_equal "My Feed", feed["title"]
  end

  def test_touch_fetched
    id = Fmog::Feed.add("https://example.com/feed.xml")
    Fmog::Feed.touch_fetched(id)
    feed = Fmog::Feed.find(id)
    refute_nil feed["last_fetched_at"]
  end
end
