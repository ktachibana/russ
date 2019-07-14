json.call(@subscription, :id, :title, :hide_default)
json.feed do
  json.call(@subscription.feed, :url, :title, :link_url, :description)
  json.items @items do |item|
    json.partial!(item)
  end
end
json.partial! 'pagination', scope: @items
json.tags @subscription.tags do |tag|
  json.partial!('tags/tags', tag: tag)
end
