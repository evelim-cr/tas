class Source < ActiveRecord::Base
	has_many :posts
	validates :name, presence: true
end
