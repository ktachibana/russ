json.call(@subscription, :id, :title)
json.feed do
  json.partial!(@subscription.feed)
end
json.tags @subscription.tags do |tag|
  json.partial!('tags/tags', tag: tag)
end
