json.partial! 'subscription', subscription: @subscription

json.feed do
  json.partial! 'feed', feed: @subscription.feed

  json.items @items do |item|
    json.partial!('item', item: item)
  end
end

json.partial! 'pagination', scope: @items if @subscription.persisted?

json.tags do
  json.partial!('tags', tags: @subscription.tags)
end
