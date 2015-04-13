class Post < ActiveRecord::Base
	belongs_to :query, :foreign_key => [:tag_id, :keyword_id, :query_id]
	belongs_to :source
end
