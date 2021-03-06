class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :text, :null => false
      t.integer :frequency
      t.string :author
      t.datetime :post_date
      t.references :source, :null => false

      t.timestamps
    end
  end
end
