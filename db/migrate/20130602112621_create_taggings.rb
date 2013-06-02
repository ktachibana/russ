class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.references :tag, index: true, null: false
      t.references :rss_source, index: true, null: false

      t.timestamps
    end
  end
end
