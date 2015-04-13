class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :text
      t.integer :frequency
      t.string :author
      t.datetime :postDate
      t.references :source_id
      t.references :query_id

      t.timestamps
    end
  end
end
