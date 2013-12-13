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
      if hs['file'].end_with?('.srt')
        SubtitleUnzipper.get_distant_path(hs['url'], hs['file'])
        subtitle = Subtitle.new(hs)
        @subtitles.push subtitle
      else
        if hs['file'].include?('zip')

          data = SubtitleUnzipper.get_distant_path(hs['url'], hs['file'])
          files = SubtitleUnzipper.unzip_file(data)

          files.each do |f|
            subtitle = Hash.new
            subtitle['file'] = f
            @subtitles.push Subtitle.new(subtitle)
          end

        end
      end
    end
    #@subtitles.each{|s| puts s.file}
    set_subtitles_of_know_team(teams)
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
          torrent_with_team = {'torrent' => torrent, 'team' => team}
          torrent_of_team_with_subtitles.push(torrent_with_team)
        end
      end
    end

    puts torrent_of_team_with_subtitles.each{|t| puts t['torrent'].seed.to_i}

    best_choice = torrent_of_team_with_subtitles.max_by{|x| x['torrent'].seed.to_i}

    if !@subtitles_of_know_teams.nil? and !best_choice.nil?
      best_choice["subtitle"] = @subtitles_of_know_teams.select{ |s| is_title_match_recognized_team(best_choice["team"], s.file)}.take(1)
      return best_choice
    else
      return nil
    end

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

  def request_torrent(request)
    encoded_request = URI::encode(request)
    urlPath = "http://kickass.to/usearch/#{encoded_request}/?rss=1"
    url = URI.parse(urlPath)
    res = Net::HTTP.get_response(url)
    return res.body
  end

  def parse_list_episode(xml_string)
    doc = Nokogiri::XML(xml_string)
    items = Array.new

    doc.xpath('//item').each do |thing|
      title = thing.at_xpath('title').content

      seeds = thing.at_xpath('torrent:seeds').content
      url = thing.at_xpath('torrent:magnetURI').content
      item = Torrent.new(title, seeds, url)
      items.push item
    end

    return items
  end


  def send_on_freebox(session_token, tv_show_name, code, torrent_url, subtitle_file )
    puts "GO SEND"
    puts session_token
    puts tv_show_name
    puts code
    puts torrent_url
    puts subtitle_file
    videos_directory = "L0Rpc3F1ZSBkdXIvVmlkw6lvcw=="
    FreeboxOSConnector.make_directory( session_token, videos_directory, tv_show_name )
    list_video_directory = FreeboxOSConnector.list_directory(session_token, videos_directory)
    directory = list_video_directory.select{ |f| f["name"] == tv_show_name and f["mimetype"] == "inode/directory"}[0]
    tv_show_directory =  directory["path"]
    FreeboxOSConnector.create_download(session_token, torrent_url, tv_show_directory)

    send_subtitle_with_movie(tv_show_directory, "#{tv_show_name} #{code}", subtitle_file , session_token)
  end

  def find_torrent(isHD, session_token)
    if isHD
      result = request_torrent( @code + " " +  tv_show_name + " 720p")
    else
      result = request_torrent( @code + " " + tv_show_name)
    end

    if result.nil?
      puts "no torrent match found for #{@tv_show_name} - #{@code}"
    else
      @torrents = parse_list_episode(result)

      @torrent_with_team = get_best_torrent

      if @torrent_with_team.nil?
        if isHD
          find_torrent(false, session_token)
        else
          puts "no match found for #{@tv_show_name} - #{@code}"
        end

      else
        puts "match found for #{@tv_show_name} - #{@code}"
        send_on_freebox(session_token, @tv_show_name, @code, @torrent_with_team["torrent"].url,  @torrent_with_team["subtitle"][0].file)


      end
    end
  end

  def is_movie(filename, movie_name)
    extensions = [".mp4", ".mkv", ".avi"]
    isMovie = extensions.any?{ |e| filename.end_with?(e)}
    if isMovie

      splited_name = movie_name.split(' ')
      splited_name.each do |s|
        if !filename.include?(s)
          return false
        end
      end
      return true
    else
      return false
    end
  end

  def send_subtitle_with_movie( directory, movie_name, subtitle_name, session_token )
    list_directory = FreeboxOSConnector.list_directory(session_token, directory)
    list_directory_without_dot_dir = list_directory.select { |d| d["name"] != "." and d["name"] != ".." }

    list_directory_without_dot_dir.each do |f|
      if f["mimetype"] == "inode/directory"
        send_subtitle_with_movie(f['path'], movie_name, subtitle_name, session_token)
      else
        if is_movie(f["name"], movie_name )
          name_srt = f["name"][0..-4] + "srt"
          puts "Session Token " + session_token
          puts directory
          puts subtitle_name
          puts name_srt
          FreeboxOSConnector.upload_file(session_token, directory, subtitle_name, name_srt)
          break
        end
      end
    end
  end

end