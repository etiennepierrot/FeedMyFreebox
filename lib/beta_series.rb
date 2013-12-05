require_relative 'torrent_selector'
require_relative 'torrent_reader'
require_relative 'parse_list_episode'
require_relative 'betaseries_connector'


class SubtitleSelector

  def fill_show_with_subtitles (show, teams, nbEpisodeMax, user_token)
    betaseries_connector = BetaseriesConnector.new()
    i = 0
    if(!show["unseen"].nil?)
      while i < 1 and !show["unseen"][i].nil?
        puts i
        puts show["unseen"][i]
        episode = show["unseen"][i]

        #puts "episode : " + episode


        episode["subtitles"] = betaseries_connector.get_subtitles(user_token, episode["id"])

        #keep only subtitle of recognized teams
        episode["subtitles"].select!{|s| teams.any?{|t| s["file"].include?(t) }}
        #episode["subtitles"].each{|s| puts s["file"]}
        #puts episode["subtitles"]
        i = i +1

      end
    end

    return show

  end

end

code = ARGV[0]
betaseries_connector = BetaseriesConnector.new()
subtitle_selector = SubtitleSelector.new()

user_token = betaseries_connector.get_user_token(code)
shows = betaseries_connector.get_episodes(user_token)
teams = ["LOL", "KILLERS", "IMMERSE", "DIMENSION", "WEB-DL", "2HD"]
NB_EPISODE_MAX = 3

#subtitle_selector.fill_show_with_subtitles(shows, teams, NB_EPISODE_MAX , user_token)
#puts shows
shows.each do |show|

  show = subtitle_selector.fill_show_with_subtitles(show, teams, NB_EPISODE_MAX , user_token)
  i = 0
  while i < 2 and !show["unseen"][i].nil?

    episode = !show["unseen"][i]
    puts episode["subtitles"][0]["files"]

    teams_who_have_subtitle = teams.select{|t| episode["subtitles"].any?{|s| s["file"].include?(t) }}
    puts teams_who_have_subtitle
    result = request_torrent( episode["code"] + " " + show["title"] + " 720p")

    if result.nil?
      puts "no torrent match found for #{show["title"]} - #{episode["code"]}"
    else
      result_parsed =  parse_list_episode(result)

      episode["torrent"] = get_best_choice(result_parsed, teams_who_have_subtitle)

      if episode["torrent"].nil?
        puts "no match found for #{show["title"]} - #{episode["code"]}"
      else
        puts "match found for #{show["title"]} - #{episode["code"]}"
      end
    end
    i = i + 1
  end


end

#show.each{|e| puts  e["unseen"][0]["title"] }













