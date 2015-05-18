class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.references :keyword, :null => false
      t.references :tag
      
      t.timestamps
    end
  end
end
