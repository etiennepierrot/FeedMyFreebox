require_relative 'episode'

class TvShow < ActiveRecord::Base
  has_many :followers
  has_many :users, through: :followers
  has_many :episodes
  attr_accessible :betaseries_id, :title

  def fetch_subtitles_available(user_token, teams)
    @episodes.each{|e| e.fetch_subtitles_available(user_token, teams)}
  end

end


