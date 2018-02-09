class DropTags < ActiveRecord::Migration[4.2]
  def change
    drop_table :taggings
    drop_table :tags
  end
end
