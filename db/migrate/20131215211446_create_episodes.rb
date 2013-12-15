class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes do |t|
      t.string :betaseries_id
      t.string :code
      t.string :tv_show_name

      t.timestamps
    end
  end
end
