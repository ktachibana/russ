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
  json.tags subscription.tags do |tag|
    json.partial!('tags/tags', tag: tag)
  end
end
json.last_page @subscriptions.last_page?
json.pagination do
  json.total_count @subscriptions.total_count
  json.per_page @subscriptions.default_per_page
end
