class AddTvShowToEpisodes < ActiveRecord::Migration
  def change
    alter_table :episodes do |e|
      e.belongs_to :tv_show
    end

  end
end
