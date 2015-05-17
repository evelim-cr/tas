class AddOriginIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :origin_id, :string
  end
end
