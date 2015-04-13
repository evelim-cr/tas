class Query < ActiveRecord::Base
	self.primary_keys = :tag_id, :keyword_id, :query_id
	belongs_to :tag
	belongs_to :keyword
	has_many :posts, :foreign_key => [:tag_id, :keyword_id, :query_id]
end
