# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :feed

  default_scope { order(published_at: :desc) }

  def self.search(user, conditions = {})
    feed_subscriptions = user.subscriptions.preload(:feed).index_by(&:feed_id)

    scope = self
    scope = scope.where(feed_id: feed_subscriptions.keys)
    conditions[:tag].presence.try do |tags|
      scope = scope.where(feed_id: Subscription.tagged_with(tags).select(:feed_id))
    end

    conditions[:subscription_id].presence.try do |subscription_id|
      scope = scope.joins(feed: :subscriptions).merge(Subscription.where(id: subscription_id))
    end

    scope = scope.page(conditions[:page])
    scope = scope.preload(:feed)
    scope.each do |item|
      item.feed.users_subscription = feed_subscriptions[item.feed_id]
    end
    scope
  end

  before_save :correct_published_at!

  def correct_published_at!
    # 一度設定した日付をnilにしてリセットはできない
    restore_published_at! if published_at.nil? && published_at_was

    # 遠い未来の日付が設定されていて、ソートでずっとトップに居座る項目が作られたことがあるため、現在時刻を上限とする
    self.published_at = [published_at, Time.current].compact.min
    self
  end
end
