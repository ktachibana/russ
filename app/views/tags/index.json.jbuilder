json.array! @tags do |tag|
  json.call(tag, :id, :name, :count)
end
