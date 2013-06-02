class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.references :user, index: true, null: false
      t.string :url, null: false
      t.string :title, null: false
      t.string :link_url
      t.text :description

      t.timestamps
    end
  end
end
