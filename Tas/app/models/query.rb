class Query < ActiveRecord::Base
	has_and_belongs_to_many :tags, :join_table => "queries_tags"
	belongs_to :keyword
	has_many :posts
end
