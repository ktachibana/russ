json.items do
  json.partial! 'application/items', items: @items
end

json.tags @tags do |tag|
  json.(tag, :id, :name, :count)
end
