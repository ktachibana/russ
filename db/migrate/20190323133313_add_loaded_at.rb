class AddLoadedAt < ActiveRecord::Migration[5.2]
  def change
    add_column :feeds, :loaded_at, :datetime, default: -> { 'now()' }
  end
end
