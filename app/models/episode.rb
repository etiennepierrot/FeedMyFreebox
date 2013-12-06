require_relative 'subtitle'
require_relative '../../lib/subtitle_unzipper'

class Episode

  attr_accessor :betaseries_id, :code, :subtitles, :torrent,:tv_show_name

  def initialize(episode_hash, tv_show_name)
    @betaseries_id = episode_hash["id"]
    @code = episode_hash["code"]
    @tv_show_name = tv_show_name
  end

  def fetch_subtitles_available(user_token, teams)
    hash_subtitles = BetaseriesConnector.get_subtitles(user_token, @betaseries_id)

    @subtitles = Array.new()
    hash_subtitles.each do |hs|
      if(hs["file"].end_with?('.srt'))
        subtitle = Subtitle.new(hs)
        @subtitles.push subtitle
      else
        if(hs["file"].include?('zip'))
          data = SubtitleUnzipper.GetDistantFile(hs["url"], hs["file"])
          subtitle_unzipper_unzip_data = SubtitleUnzipper.UnzipData(data)
          subtitle_unzipper_unzip_data.each{|s| @subtitles.push s}
        end
      end
    end

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
        @subtitles.each{|s| puts s.file }
        result_parsed.each{|t| puts t.title}
        puts "no match found for #{@tv_show_name} - #{@code}"
      else
        puts "match found for #{@tv_show_name} - #{@code}"

      end
    end
  end

end