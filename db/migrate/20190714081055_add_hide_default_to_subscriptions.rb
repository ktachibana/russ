class AddHideDefaultToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :hide_default, :boolean, null: false, default: false
  end
end
