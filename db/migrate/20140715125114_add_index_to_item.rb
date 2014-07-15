class AddIndexToItem < ActiveRecord::Migration
  def change
    add_index :items, :published_at
  end
end
