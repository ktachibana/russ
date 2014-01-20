json = JSON.load ARGF.read

json['tags'].each do |tag|
  attrs = { name: tag['name'] }
  p ActsAsTaggableOn::Tag.create(attrs)
end
json['taggings'].each do |tagging|
  attrs = { tag_id: tagging['tag_id'],
            taggable: Feed.find(tagging['feed_id']),
            context: 'tags',
            created_at: tagging['created_at'] }
  p ActsAsTaggableOn::Tagging.create(attrs)
end
