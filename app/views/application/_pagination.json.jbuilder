json.pagination do
  json.total_count scope.total_count
  json.per_page scope.default_per_page
end
