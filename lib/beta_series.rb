require_relative 'torrent_selector'
require_relative 'torrent_reader'
require_relative 'parse_list_episode'
require_relative 'betaseries_connector'
require_relative '../app/models/tv_show'

code = ARGV[0]
#betaseries_connector = BetaseriesConnector.new()

user_token = BetaseriesConnector.get_user_token(code)
shows = BetaseriesConnector.get_episodes(user_token)
teams = ["LOL", "KILLERS", "IMMERSE", "DIMENSION", "WEB-DL", "2HD"]
NB_EPISODE_MAX = 3

tv_shows = shows.map { |s| TvShow.new(s, NB_EPISODE_MAX)}

tv_shows.each do |tv_show|
  tv_show.fetch_subtitles_available(user_token, teams)
  tv_show.episodes.each do |episode|
    teams_who_have_subtitle = teams.select{|t| episode.subtitles.any?{|s| s.file.include?(t) }}
    episode.find_torrent(teams_who_have_subtitle)
  end
end















