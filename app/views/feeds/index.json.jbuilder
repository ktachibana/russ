json.subscriptions @subscriptions do |subscription|
  json.call(subscription, :id, :user_title)

  json.feed do
    feed = subscription.feed
    json.call(feed, :id, :title)

    subscription.feed.latest_item.try do |item|
      json.latest_item do
        json.call(item, :title)
      end
    end
  end
end
json.last_page @subscriptions.last_page?
