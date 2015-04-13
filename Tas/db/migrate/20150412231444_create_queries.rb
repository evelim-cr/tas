class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries, :id => false do |t|
      t.integer :query_id
      t.references :keyword
      t.references :tag

      t.timestamps
    end
  	add_index :queries, [:query_id, :keyword_id, :tag_id], unique: true, name: "by_query_composite_id"
  end
end
