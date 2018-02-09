class AddCreatedAtIndexToItems < ActiveRecord::Migration[4.2]
  def change
    add_index :items, :created_at
  end
end
