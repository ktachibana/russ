json.call(feed, :url, :title, :link_url, :description)
json.items feed.items do |item|
  json.partial!(item)
end
