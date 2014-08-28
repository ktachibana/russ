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
end
