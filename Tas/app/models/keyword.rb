class Keyword < ActiveRecord::Base
	has_many :queries
	has_many :tags, through: :queries
end
