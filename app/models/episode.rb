require_relative 'subtitle'
require_relative '../../lib/subtitle_unzipper'

class Episode

  attr_accessor :betaseries_id, :code, :subtitles, :torrent,:tv_show_name, :teams_who_have_subtitles, :torrents,
                :subtitles_of_know_teams

  def initialize(episode_hash, tv_show_name)
    @betaseries_id = episode_hash["id"]
    @code = episode_hash["code"]
    @tv_show_name = tv_show_name
    @teams_who_have_subtitles = Array.new
    @torrents = Array.new
    @subtitles_of_know_teams = Array.new
  end

  def fetch_subtitles_available(user_token, teams)

    puts "fetch #{@tv_show_name} #{@code}"
    hash_subtitles = BetaseriesConnector.get_subtitles(user_token, @betaseries_id)

    @subtitles = Array.new
    hash_subtitles.each do |hs|
      if hs["file"].end_with?('.srt')
        subtitle = Subtitle.new(hs)
        @subtitles.push subtitle
      else
        if hs["file"].include?('zip')
          data = SubtitleUnzipper.GetDistantFile(hs["url"], hs["file"])
          subtitle_unzipper_unzip_data = SubtitleUnzipper.UnzipData(data)
          subtitle_unzipper_unzip_data.each{|s| @subtitles.push s}
        end
      end
    end
    set_subtitles_of_know_team(teams)
    #puts "Subtitle of know team :"
    #puts @subtitles_of_know_teams.count
  end

  def set_subtitles_of_know_team(teams)
    @subtitles.each do |subtitle|
      teams.each do |team|
        if is_title_match_recognized_team(team, subtitle.file)
          @subtitles_of_know_teams.push subtitle
          @teams_who_have_subtitles.push team
        end
      end
    end
  end

  def get_best_torrent
    torrent_of_team_with_subtitles = Array.new
    @torrents.each do |torrent|
      @teams_who_have_subtitles.each do |team|
        if is_title_match_recognized_team(team, torrent.title)
          torrent_of_team_with_subtitles.push torrent
        end
      end
    end

    best_choice = torrent_of_team_with_subtitles.max_by(&:seed)
    return best_choice
  end

  def is_title_match_recognized_team(team, title)
    team.each do |naming|
      if title.upcase.include?(naming.upcase)
        return true
        break
      end
    end
    return false
  end

  def find_torrent(isHD)
    if isHD
      result = request_torrent( @code + " " +  @tv_show_name + " 720p")
    else
      result = request_torrent( @code + " " +  @tv_show_name)
    end

    if result.nil?
      puts "no torrent match found for #{@tv_show_name} - #{@code}"
    else
      @torrents = parse_list_episode(result)

      @torrent = get_best_torrent

      if @torrent.nil?
        #@subtitles.each{|s| puts s.file }
        #@torrents.each{|t| puts t.title}
        if isHD
          find_torrent(false)
        else
          puts "no match found for #{@tv_show_name} - #{@code}"
        end

      else
        puts "match found for #{@tv_show_name} - #{@code}"
      end
    end
  end

end