class Torrent < ActiveRecord::Base
  belongs_to :team
  attr_accessible :title, :seed, :url, :isHD

  def name
    return title
  end

end