class AddTorrentToEpisodes < ActiveRecord::Migration
  def change
    alter_table :episodes do |e|
      e.belongs_to :torrent
      e.belongs_to :subtitle
    end
  end
end
