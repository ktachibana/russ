class RemoveUserIdFromFeeds < ActiveRecord::Migration[4.2]
  def change
    remove_column :feeds, :user_id
  end
end
