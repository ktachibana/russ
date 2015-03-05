json.items items do |item|
  json.call(item, :id, :feed_id, :title, :link, :description)
  json.feed do
    json.call(item.feed, :id, :url, :title, :link_url, :description)
    json.users_subscription do
      json.call(item.feed.users_subscription, :id, :user_title)
    end
  end
end
json.last_page items.last_page?
