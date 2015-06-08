class Tag < ActiveRecord::Base
	has_and_belongs_to_many :queries, :join_table => "queries_tags"
end
