class CreateFreeboxes < ActiveRecord::Migration
  def change
    create_table :freeboxes do |t|
      t.integer :track_authorization_id
      t.string :app_token
      t.string :app_name
      t.string :app_id
      t.string :app_version
      t.belongs_to :users

      t.timestamps
    end
  end
end
