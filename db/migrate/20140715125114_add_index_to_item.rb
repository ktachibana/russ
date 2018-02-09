class AddIndexToItem < ActiveRecord::Migration[4.2]
  def change
    add_index :items, :published_at
  end
end
