json.items @items do |item|
  json.partial! 'item', item: item

  json.feed do
    feed = item.feed

    json.partial! 'feed', feed: feed

    json.users_subscription do
      json.partial! 'users_subscription', users_subscription: feed.users_subscription
    end
  end
end

json.partial! 'pagination', scope: @items
