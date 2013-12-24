class AddTorrentFileUrlToTorrents < ActiveRecord::Migration
  def change
    add_column :torrents, :torrent_file_url, :string
  end
end
