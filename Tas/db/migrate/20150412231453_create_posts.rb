class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :text
      t.integer :frequency
      t.string :author
      t.datetime :postDate
      t.references :source
      t.references :query

      t.timestamps
    end
  end
end
