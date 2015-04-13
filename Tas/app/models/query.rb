class Query < ActiveRecord::Base
	belongs_to :tag
	belongs_to :keyword
	has_many :posts
end
