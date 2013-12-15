class CreateFollowers < ActiveRecord::Migration
  def change

    create_table :tv_shows do |t|
      t.string :betaseries_id
      t.string :title
      t.timestamps
    end

    create_table :followers do |t|
      t.belongs_to :tv_show
      t.belongs_to :user
      t.timestamps
    end
  end
end