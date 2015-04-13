json.array!(@posts) do |post|
  json.extract! post, :id, :text, :frequency, :author, :postDate, :source_id, :query_id
  json.url post_url(post, format: :json)
end
