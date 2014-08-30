json.items items do |item|
  json.(item, :id, :feed_id, :title, :link, :description)
  json.feed do
    json.(item.feed, :id, :url, :title, :link_url, :description)
    json.users_subscription do
      json.(item.feed.users_subscription, :id, :user_title)
    end
  end
end
json.last_page items.last_page?
