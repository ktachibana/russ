class ItemSearcher
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :user
  attribute :tag, :string, array: true
  attribute :subscription_id, :integer
  attribute :hide_default, :boolean
  attribute :page, :integer

  def search
    result = Item.all
    result = result.where(feed_id: user.subscriptions.select(:feed_id))
    tag.presence.try do |tags|
      result = result.where(feed_id: Subscription.tagged_with(tags).select(:feed_id))
    end

    subscription_id.presence.try do |subscription_id|
      result = result.joins(feed: :subscriptions).merge(Subscription.where(id: subscription_id))
    end

    if hide_default && [tag, subscription_id].all?(&:blank?)
      result = result.joins(feed: :subscriptions).merge(Subscription.default)
    end

    result = result.page(page)
    result = result.preload(:feed)
    feed_subscriptions = user.subscriptions.preload(:feed).index_by(&:feed_id)
    result.each do |item|
      item.feed.users_subscription = feed_subscriptions[item.feed_id]
    end
    result
  end
end
