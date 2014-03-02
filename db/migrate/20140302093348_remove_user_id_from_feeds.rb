class RemoveUserIdFromFeeds < ActiveRecord::Migration
  def change
    remove_column :feeds, :user_id
  end
end
