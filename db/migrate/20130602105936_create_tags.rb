class CreateTags < ActiveRecord::Migration[4.2]
  def change
    create_table :tags do |t|
      t.references :user, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
