class AddRememberableToUser < ActiveRecord::Migration[4.2]
  def change
    change_table :users do |t|
      ## Rememberable
      t.datetime :remember_created_at
    end
  end
end
