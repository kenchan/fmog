# frozen_string_literal: true

require_relative "test_helper"

class TestItem < FmogTestCase
  def setup
    super
    @feed_id = Fmog::Feed.add("https://example.com/feed.xml")
  end

  def test_upsert_creates_item
    Fmog::Item.upsert(
      feed_id: @feed_id, guid: "guid-1", title: "Title",
      url: "http://example.com/1", body: "Body", published_at: "2024-01-01 00:00:00"
    )
    items = Fmog::Item.list(feed_id: @feed_id)
    assert_equal 1, items.length
    assert_equal "Title", items[0]["title"]
    assert_equal "Body", items[0]["body"]
  end

  def test_upsert_updates_on_conflict
    Fmog::Item.upsert(feed_id: @feed_id, guid: "guid-1", title: "Old", url: nil, body: "Old body", published_at: nil)
    Fmog::Item.upsert(feed_id: @feed_id, guid: "guid-1", title: "New", url: nil, body: "New body", published_at: nil)
    items = Fmog::Item.list(feed_id: @feed_id)
    assert_equal 1, items.length
    assert_equal "New", items[0]["title"]
    assert_equal "New body", items[0]["body"]
  end

  def test_upsert_allows_same_guid_different_feeds
    feed2 = Fmog::Feed.add("https://example.com/feed2.xml")
    Fmog::Item.upsert(feed_id: @feed_id, guid: "same-guid", title: "Feed1", url: nil, body: nil, published_at: nil)
    Fmog::Item.upsert(feed_id: feed2, guid: "same-guid", title: "Feed2", url: nil, body: nil, published_at: nil)
    assert_equal 1, Fmog::Item.list(feed_id: @feed_id).length
    assert_equal 1, Fmog::Item.list(feed_id: feed2).length
  end

  def test_list_orders_by_published_at_desc
    Fmog::Item.upsert(feed_id: @feed_id, guid: "old", title: "Old", url: nil, body: nil, published_at: "2024-01-01 00:00:00")
    Fmog::Item.upsert(feed_id: @feed_id, guid: "new", title: "New", url: nil, body: nil, published_at: "2024-02-01 00:00:00")
    items = Fmog::Item.list
    assert_equal "New", items[0]["title"]
    assert_equal "Old", items[1]["title"]
  end

  def test_list_with_limit
    3.times do |i|
      Fmog::Item.upsert(feed_id: @feed_id, guid: "g#{i}", title: "T#{i}", url: nil, body: nil, published_at: nil)
    end
    items = Fmog::Item.list(limit: 2)
    assert_equal 2, items.length
  end

  def test_list_unread_filter
    Fmog::Item.upsert(feed_id: @feed_id, guid: "g1", title: "T1", url: nil, body: nil, published_at: nil)
    Fmog::Item.upsert(feed_id: @feed_id, guid: "g2", title: "T2", url: nil, body: nil, published_at: nil)
    item = Fmog::Item.list.first
    Fmog::Item.mark_read(item["id"])

    unread = Fmog::Item.list(unread: true)
    assert_equal 1, unread.length
  end

  def test_list_feed_filter
    feed2 = Fmog::Feed.add("https://example.com/feed2.xml")
    Fmog::Item.upsert(feed_id: @feed_id, guid: "g1", title: "Feed1 Item", url: nil, body: nil, published_at: nil)
    Fmog::Item.upsert(feed_id: feed2, guid: "g2", title: "Feed2 Item", url: nil, body: nil, published_at: nil)

    items = Fmog::Item.list(feed_id: @feed_id)
    assert_equal 1, items.length
    assert_equal "Feed1 Item", items[0]["title"]
  end

  def test_list_combined_filters
    feed2 = Fmog::Feed.add("https://example.com/feed2.xml")
    Fmog::Item.upsert(feed_id: @feed_id, guid: "g1", title: "Read", url: nil, body: nil, published_at: nil)
    Fmog::Item.upsert(feed_id: @feed_id, guid: "g2", title: "Unread", url: nil, body: nil, published_at: nil)
    Fmog::Item.upsert(feed_id: feed2, guid: "g3", title: "Other", url: nil, body: nil, published_at: nil)
    read_item = Fmog::Item.list.find { |i| i["title"] == "Read" }
    Fmog::Item.mark_read(read_item["id"])

    items = Fmog::Item.list(feed_id: @feed_id, unread: true)
    assert_equal 1, items.length
    assert_equal "Unread", items[0]["title"]
  end

  def test_find_existing
    Fmog::Item.upsert(feed_id: @feed_id, guid: "g1", title: "Test", url: "http://x", body: "Content", published_at: nil)
    item = Fmog::Item.list.first
    found = Fmog::Item.find(item["id"])
    assert_equal "Test", found["title"]
    assert_equal "Content", found["body"]
  end

  def test_find_nonexistent
    assert_nil Fmog::Item.find(999)
  end

  def test_mark_read
    Fmog::Item.upsert(feed_id: @feed_id, guid: "g1", title: "T", url: nil, body: nil, published_at: nil)
    item = Fmog::Item.list.first
    count = Fmog::Item.mark_read(item["id"])
    assert_equal 1, count
    refute_nil Fmog::Item.find(item["id"])["read_at"]
  end

  def test_mark_unread
    Fmog::Item.upsert(feed_id: @feed_id, guid: "g1", title: "T", url: nil, body: nil, published_at: nil)
    item = Fmog::Item.list.first
    Fmog::Item.mark_read(item["id"])
    count = Fmog::Item.mark_unread(item["id"])
    assert_equal 1, count
    assert_nil Fmog::Item.find(item["id"])["read_at"]
  end

  def test_mark_read_nonexistent
    count = Fmog::Item.mark_read(999)
    assert_equal 0, count
  end

  def test_mark_unread_nonexistent
    count = Fmog::Item.mark_unread(999)
    assert_equal 0, count
  end
end
