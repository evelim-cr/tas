class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries, :id => false do |t|
      t.integer :query_id, :null => false
      t.references :keyword, :null => false
      t.references :tag, :null => false

      t.timestamps
    end
  	add_index :queries, [:query_id, :keyword_id, :tag_id], unique: true, name: "by_query_composite_id"
  end
end
