json.call(@subscription, :id, :title)
json.feed do
  json.call(@subscription.feed, :url, :title, :link_url, :description)
  json.items @items do |item|
    json.partial!(item)
  end
end
json.last_page @items.last_page?
json.pagination do
  json.total_count @items.total_count
  json.per_page @items.default_per_page
end

json.tags @subscription.tags do |tag|
  json.partial!('tags/tags', tag: tag)
end
