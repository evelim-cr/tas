# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Source.create(name: 'Reddit')
Source.create(name: 'Youtube')
Source.create(name: 'Twitter')

k=Keyword.create(name: 'dog')
t1= Tag.create(name: 'doge')
t2= Tag.create(name: 'xiuaua')
t3= Tag.create(name: 'tita')

Query.create(keyword: k, tags: [t1, t2, t3])
