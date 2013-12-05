require_relative 'torrent_selector'
require_relative 'torrent_reader'
require_relative 'parse_list_episode'
require_relative 'betaseries_connector'


class SubtitleSelector

  def 
    
  end

end

code = ARGV[0]
betaseries_connector = BetaseriesConnector.new()
user_token = betaseries_connector.get_user_token(code)
shows = betaseries_connector.get_episodes(user_token)
teams = ["LOL", "KILLERS", "IMMERSE", "DIMENSION", "WEB-DL", "2HD"]

shows.each do |s|

  episode = s["unseen"][0]
  puts  episode["id"].to_s + " - " + s["title"] + " - " + episode["code"] + " _ " + episode["title"]
  episode["subtitles"] = betaseries_connector.get_subtitles(user_token, episode["id"])

  #keep only subtitle of recognized teams
  episode["subtitles"].select!{|s| teams.any?{|t| s["file"].include?(t) }}
  episode["subtitles"].each{|s| puts s["file"]}

  teams_who_have_subtitle = teams.select{|t| episode["subtitles"].any?{|s| s["file"].include?(t) }}

  result = request_torrent( episode["code"] + " " + s["title"] + " 720p")

  if result.nil?
    puts "no torrent match found for #{s["title"]} - #{episode["code"]}"
  else
    result_parsed =  parse_list_episode(result)

    episode["torrent"] = get_best_choice(result_parsed, teams_who_have_subtitle)

    if episode["torrent"].nil?
      puts "no match found for #{s["title"]} - #{episode["code"]}"
    else
      puts "match found for #{s["title"]} - #{episode["code"]}"
    end
  end
end

#shows.each{|e| puts  e["unseen"][0]["title"] }













