class CreateRssSources < ActiveRecord::Migration
  def change
    create_table :rss_sources do |t|
      t.references :user, index: true, null: false
      t.string :url, null: false
      t.string :title, null: false
      t.string :link_url
      t.text :description

      t.timestamps
    end
  end
end
