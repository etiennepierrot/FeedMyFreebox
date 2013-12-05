require_relative 'torrent_selector'
require_relative 'torrent_reader'
require_relative 'parse_list_episode'
require_relative 'betaseries_connector'


class SubtitleSelector

  def create_episodes_with_subtitles (episodes, teams, nbEpisodeMax, user_token)

    betaseries_connector = BetaseriesConnector.new()
    i = 0

    unless episodes.nil?
      while i < nbEpisodeMax and !episodes[i].nil?

        episode = episodes[i]
        episode["subtitles"] = betaseries_connector.get_subtitles(user_token, episode["id"])
        episode["subtitles"].select! { |s| teams.any? { |t| s["file"].include?(t) } }
        i = i +1
      end
    end

    return episodes

  end

end

def find_torrent(episode, teams_who_have_subtitle)

  result = request_torrent( episode["code"] + " " + episode["show_name"] + " 720p")

  if result.nil?
    puts "no torrent match found for #{episode["show_name"]} - #{episode["code"]}"
  else
    result_parsed = parse_list_episode(result)

    episode["torrent"] = get_best_choice(result_parsed, teams_who_have_subtitle)

    if episode["torrent"].nil?
      puts "no match found for #{episode["show_name"]} - #{episode["code"]}"
    else
      puts "match found for #{episode["show_name"]} - #{episode["code"]}"
    end
  end
end

code = ARGV[0]
betaseries_connector = BetaseriesConnector.new()
subtitle_selector = SubtitleSelector.new()

user_token = betaseries_connector.get_user_token(code)
shows = betaseries_connector.get_episodes(user_token)
teams = ["LOL", "KILLERS", "IMMERSE", "DIMENSION", "WEB-DL", "2HD"]

NB_EPISODE_MAX = 3

shows.each do |show|

  episodes = subtitle_selector.create_episodes_with_subtitles(show["unseen"], teams, NB_EPISODE_MAX , user_token)
  i = 0
  while i < NB_EPISODE_MAX and !show["unseen"][i].nil?

    episode = episodes[i]
    episode["show_name"] = show["title"]
    teams_who_have_subtitle = teams.select{|t| episode["subtitles"].any?{|s| s["file"].include?(t) }}
    find_torrent(episode, teams_who_have_subtitle)
    i = i + 1

  end


end















