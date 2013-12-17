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



end