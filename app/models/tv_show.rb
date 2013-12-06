require_relative 'episode'

class TvShow
  attr_accessor :betaseries_id, :title, :episodes, :subtitles_available

  def initialize(hash_show, nb_episode_max)
    @betaseries_id = hash_show["id"]
    @title = hash_show["title"]
    @episodes = hash_show["unseen"][0..nb_episode_max].map{|e| Episode.new(e,hash_show["title"])}
  end

  def fetch_subtitles_available(user_token, teams)
    @episodes.each{|e| e.fetch_subtitles_available(user_token, teams)}
  end

end
