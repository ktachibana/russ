json.call(@feed, :url, :title, :link_url, :description)
json.items @feed.items do |item|
  json.call(item, :title, :link, :guid, :published_at, :description)
end
