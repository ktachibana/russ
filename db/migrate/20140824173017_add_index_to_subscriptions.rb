class AddIndexToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_index :subscriptions, :created_at
  end
end
