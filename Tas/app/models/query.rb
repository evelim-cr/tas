class Query < ActiveRecord::Base
	has_and_belongs_to_many :tags, :join_table => "queries_tags"
	belongs_to :keyword
	has_many :posts

	def self.getQuery(keyword, tags)
		# Faz o join de queries com queries_tags
		# Filtra somente as queries com a keyword procurada
		# Retorna as queries que possuem QUALQUER uma das tags procuradas
		querys_with_keyword = self.joins(:queries_tags).where(:keyword => keyword).where(:queries_tags => {:tag => tags}) 

		# Se uma das querys tiver o numero de tags igual ao numero de tags procuradas 
		# Entao encontrou um query igual
		querys_with_keyword.select { |q| q.tags.count == tags.count } 
		if querys_with_keyword.empty?
			q = self.new(:keyword => keyword)
			q.tags=tags
			q.save!
			return q
		else
			return querys_with_keyword
		end
	end
end
