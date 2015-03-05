class Item < ActiveRecord::Base
  belongs_to :feed

  default_scope { order(published_at: :desc) }

  def self.search(user, conditions = {})
    feed_subscriptions = user.subscriptions.includes(:feed).index_by(&:feed_id)

    scope = self
    scope = scope.where(feed_id: feed_subscriptions.keys)
    conditions[:tag].presence.try do |tags|
      scope = scope.where(feed_id: Subscription.tagged_with(tags).pluck(:feed_id))
    end

    scope = scope.page(conditions[:page])
    scope = scope.includes(:feed)
    scope.each do |item|
      item.feed.users_subscription = feed_subscriptions[item.feed_id]
    end
    scope
  end

  before_save :corrent_published_at!

  def corrent_published_at!
    # 遠い未来の日付が設定されていて、ソートでずっとトップに居座る項目が作られたことがあるため、現在時刻を上限とする
    self.published_at = [published_at, Time.current].compact.min
    self
  end
end
