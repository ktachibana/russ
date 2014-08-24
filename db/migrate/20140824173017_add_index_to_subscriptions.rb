class AddIndexToSubscriptions < ActiveRecord::Migration
  def change
    add_index :subscriptions, :created_at
  end
end
