class CreateSubscriptions < ActiveRecord::Migration[4.2]
  def change
    create_table :subscriptions do |t|
      t.references :user, index: true
      t.references :feed, index: true
      t.string :title

      t.timestamps
    end
  end
end
