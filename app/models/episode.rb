require_relative 'subtitle'
require_relative '../../lib/subtitle_unzipper'

class Episode < ActiveRecord::Base
  has_many :subtitles
  has_many :torrents
  belongs_to :tv_show
  belongs_to :torrent
  belongs_to :subtitle

  attr_accessible :betaseries_id, :code, :tv_show_name

end