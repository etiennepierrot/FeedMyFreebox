class CreateTorrents < ActiveRecord::Migration
  def change
    create_table :torrents do |t|
      t.belongs_to :team
      t.belongs_to :episode
      t.string :title
      t.string :url
      t.boolean :isHD
      t.integer :seed

      t.timestamps
    end
  end
end
