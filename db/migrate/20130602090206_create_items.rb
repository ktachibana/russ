class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.references :feed, index: true, null: false
      t.string :title
      t.string :link, limit: 2048
      t.string :guid
      t.datetime :published_at
      t.text :description

      t.timestamps
    end
  end
end
