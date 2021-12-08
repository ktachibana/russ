# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :feed
  acts_as_taggable

  accepts_nested_attributes_for :feed

  validates :user_id, presence: true
  validates :title, length: { maximum: 255 }
  validates :feed_id, uniqueness: { scope: :user_id }

  default_scope -> { order(created_at: :desc) }

  scope :search, lambda { |conditions|
    scope = self
    conditions[:tag].presence.try do |tag_names|
      scope = scope.tagged_with(tag_names)
    end
    scope = scope.page(conditions[:page])
    scope
  }

  scope :url, ->(url) { joins(:feed).merge(Feed.where(url: url)) }
  scope :default, -> { where(hide_default: false) }

  class AlreadySubscribed < StandardError
    attr_reader :subscription

    def initialize(subscription)
      @subscription = subscription
    end
  end

  class FeedNotFound < StandardError; end

  def self.prefetch(url)
    require_not_subscribed(url)

    feed_url = Feedbag.find(url)[0]
    raise FeedNotFound unless feed_url
    require_not_subscribed(feed_url)

    feed = Feed.find_or_initialize_by(url: feed_url)
    feed.load! if feed.new_record?

    new(feed: feed)
  end

  def self.require_not_subscribed(url)
    url(url).first.try! do |subscription|
      raise AlreadySubscribed.new(subscription)
    end
  end

  # XXX: もっとスマートにしたい
  def subscribe!
    persisted_feed = Feed.find_by(url: feed.url)
    if persisted_feed
      self.feed = persisted_feed
    else
      feed.load!
      feed.save!
    end
    save!
  end

  def user_title
    title.presence || feed.title
  end

  def tags_string
    tags.map(&:name).join(', ')
  end
end
