class Tag < ActiveRecord::Base
	has_many :queries
	has_many :keywords, through: :queries
end
