class CreateJoinTable < ActiveRecord::Migration
  def up
    create_table :queries_tags, :id => false do |t|
      t.references :query, :tag
    end
  end

  def down
    drop_table :queries_tags
  end
end
