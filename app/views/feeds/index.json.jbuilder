json.subscriptions @subscriptions do |subscription|
  json.partial! 'users_subscription', users_subscription: subscription

  json.feed do
    feed = subscription.feed

    json.partial! 'feed', feed: feed

    feed.latest_item.try! do |latest_item|
      json.latest_item do
        json.partial! 'item', item: latest_item
      end
    end
  end

  json.tags do
    json.partial!('tags', tags: subscription.tags)
  end
end

json.partial! 'pagination', scope: @subscriptions
