class AddRememberableToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      ## Rememberable
      t.datetime :remember_created_at
    end
  end
end
