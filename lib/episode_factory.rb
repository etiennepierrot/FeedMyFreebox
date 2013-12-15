module EpisodeFactory

  def self.create_episode(episode_hash, tv_show_name, user_token)

    Rails.logger.info "Create Episode :"
    episode = Episode.find_by_betaseries_id(episode_hash["id"])

    if episode.nil?
      episode = Episode.new
      episode.betaseries_id = episode_hash["id"]
      episode.code = episode_hash["code"]
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

    episode.save!

    #e.teams_who_have_subtitles = Array.new
    #e.torrents = Array.new
    #e.subtitles_of_know_teams = Array.new
    return episode
  end

  def self.fetch_subtitles_available(episode, user_token, teams)

    puts "fetch #{episode.tv_show_name} #{episode.code}"
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

end