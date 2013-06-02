class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.references :user, index: true, null: false
      t.string :url, null: false, limit: 2048
      t.string :title, null: false, limit: 255
      t.string :link_url, limit: 2048
      t.text :description, limit: 4096

      t.timestamps
    end
  end
end
