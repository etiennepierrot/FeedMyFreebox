class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :betaseries_id
      t.string :betaseries_login
      t.string :betaseries_token

      t.timestamps
    end
  end
end
