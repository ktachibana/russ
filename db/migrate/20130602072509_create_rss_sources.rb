class CreateRssSources < ActiveRecord::Migration
  def change
    create_table :rss_sources do |t|
      t.references :user, index: true
      t.string :title
      t.string :url
      t.string :describe

      t.timestamps
    end
  end
end
