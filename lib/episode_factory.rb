module EpisodeFactory

  def self.create_episode(episode_hash, tv_show_name, user_token)

    Rails.logger.info 'Create Episode :'
    episode = Episode.find_by_betaseries_id(episode_hash['id'])

    if episode.nil?
      episode = Episode.new
      episode.betaseries_id = episode_hash['id']
      episode.code = episode_hash['code']
      episode.tv_show_name = tv_show_name
    end


    Rails.logger.info episode.to_yaml

    hash_subtitles = BetaseriesConnector.get_subtitles(user_token, episode.betaseries_id)
    #Rails.logger.info hash_subtitles.to_yaml
    hash_subtitles.each do |hs|
      subtitles = SubtitleFactory.create_subtitle(hs)
      if !subtitles.nil?
        subtitles.each do |s|
          if !episode.subtitles.include?(s)
            episode.subtitles.push(s)
          end
        end
      end
    end

    TorrentFactory.find_torrent(episode)

    episode.save!
    return episode
  end

  def self.get_best_torrent(episode, is_hd)

    torrents = Array.new

    episode.subtitles.each do |s|
      unless s.team.nil?
        episode.torrents.each do |t|
          if t.team == s.team and t.isHD == is_hd
            couple = {
                'torrent' => t,
                'subtitle' => s
            }
            torrents.push couple
          end
        end
      end
    end

    if !torrents.nil? and torrents.length > 0
      picked_couple = torrents.max_by{|t| t['torrent'].seed}
      episode.torrent = picked_couple['torrent']
      episode.subtitle = picked_couple['subtitle']
      episode.save!
    end
  end

  def self.send(session_token, episode)
    videos_directory = "L0Rpc3F1ZSBkdXIvVmlkw6lvcw=="
    FreeboxOSConnector.make_directory( session_token, videos_directory, episode.tv_show_name )
    list_video_directory = FreeboxOSConnector.list_directory(session_token, videos_directory)
    directory = list_video_directory.select{ |f| f["name"] == episode.tv_show_name and f["mimetype"] == "inode/directory"}[0]
    tv_show_directory =  directory["path"]
    FreeboxOSConnector.create_download(session_token, episode.torrent.url, tv_show_directory)
    Rails.logger.info episode.subtitle.path
    send_subtitle_with_movie(tv_show_directory, "#{episode.tv_show_name} #{episode.code}", episode.subtitle.path , session_token)
  end


  def self.is_movie(filename, movie_name)
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

  def self.send_subtitle_with_movie( directory, movie_name, subtitle_name, session_token )
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