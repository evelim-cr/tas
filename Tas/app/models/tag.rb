# encoding: UTF-8
class Tag < ActiveRecord::Base
	has_and_belongs_to_many :queries, :join_table => "queries_tags"
	validates :name, presence: true

	def self.getTag(tag)
		@tg = where(:name => tag).first
		if @tg.nil?
			@tg = Tag.new(:name => tag)
			@tg.save
		end
		return @tg	
	end	
end

