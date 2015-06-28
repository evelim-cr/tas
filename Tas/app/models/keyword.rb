class Keyword < ActiveRecord::Base
	has_many :queries
	has_many :tags, through: :queries
	validates :name, presence: true

	def self.getKeyword(keyword)
		@k1 = where(:name => keyword).first
		if @k1.nil?
			@k1 = Keyword.new(:name => keyword)
			@k1.save
		end
		return @k1
	end
end
