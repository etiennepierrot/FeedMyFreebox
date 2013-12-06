require_relative 'subtitle'

class Episode

  attr_accessor :betaseries_id, :code, :subtitles, :torrent,:tv_show_name

  def initialize(episode_hash, tv_show_name)
    @betaseries_id = episode_hash["id"]
    @code = episode_hash["code"]
    @tv_show_name = tv_show_name
  end

  def fetch_subtitles_available(user_token, teams)
    hash_subtitles = BetaseriesConnector.get_subtitles(user_token, @betaseries_id)
    @subtitles = hash_subtitles.map{|s| Subtitle.new(s)}
    @subtitles.select! { |s| teams.any? { |t| s.file.include?(t) } }

  end

  def find_torrent(teams_who_have_subtitle)

    result = request_torrent( @code + " " +  @tv_show_name + " 720p")

    if result.nil?
      puts "no torrent match found for #{@tv_show_name} - #{@code}"
    else
      result_parsed = parse_list_episode(result)

      @torrent = get_best_choice(result_parsed, teams_who_have_subtitle)

      if @torrent.nil?
        puts "no match found for #{@tv_show_name} - #{@code}"
      else
        puts "match found for #{@tv_show_name} - #{@code}"
      end
    end
  end

end