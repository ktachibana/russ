class AddCreatedAtIndexToItems < ActiveRecord::Migration
  def change
    add_index :items, :created_at
  end
end
