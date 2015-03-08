json.array! @tags do |tag|
  json.partial!('tags/tags', tag: tag)
end
