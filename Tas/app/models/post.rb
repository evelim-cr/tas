class Post < ActiveRecord::Base
	belongs_to :query
	belongs_to :source
end
