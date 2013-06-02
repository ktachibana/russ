class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.references :feed, index: true, null: false
      t.string :title
      t.string :link
      t.datetime :published_at
      t.string :description

      t.timestamps
    end
  end
end
