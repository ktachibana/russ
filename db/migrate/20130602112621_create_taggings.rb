class CreateTaggings < ActiveRecord::Migration[4.2]
  def change
    create_table :taggings do |t|
      t.references :tag, index: true, null: false
      t.references :feed, index: true, null: false

      t.timestamps
    end
  end
end
