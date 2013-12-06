require_relative 'torrent_reader'
require_relative 'parse_list_episode'
require_relative 'betaseries_connector'
require_relative '../app/models/tv_show'

code = ARGV[0]


user_token = BetaseriesConnector.get_user_token(code)
shows = BetaseriesConnector.get_episodes(user_token)
teams = [ ["LOL"], ["KILLERS"], ["IMMERSE", "IMM"], ["DIMENSION","DIM"], ["WEB-DL"], ["2HD"], ["ASAP"]]
NB_EPISODE_MAX = 3

tv_shows = shows.map { |s| TvShow.new(s, NB_EPISODE_MAX)}
#tv_shows = Array.new
#tv_shows.push TvShow.new(shows[0], NB_EPISODE_MAX)

tv_shows.each do |tv_show|
  tv_show.fetch_subtitles_available(user_token, teams)
  tv_show.episodes.each do |episode|
    episode.find_torrent()
  end
end













