class Torrent < ActiveRecord::Base
  belongs_to :team
  attr_accessible :title, :seed, :url, :isHD, :torrent_file_url

  def name
    return title
  end

end