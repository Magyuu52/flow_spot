class AddSearchIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :posts, :user_id
    add_index :posts, :created_at

    add_index :users, :name
  end
end
