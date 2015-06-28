class CreateJoinTableQueryPost < ActiveRecord::Migration
  def up
    create_table :queries_posts, :id => false do |t|
      t.references :query, :post
      t.index [:query_id, :post_id]
      t.index [:post_id, :query_id]
    end
  end

  def down
    drop_table :queries_posts
  end
end
