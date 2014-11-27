json.array!(entries) do |entry|
  json.extract! entry, :id, *default_crud_attrs
  json.url polymorphic_url(path_args(entry), format: :json)
end
