class EpisodeController < ApplicationController
  def update
    @user = User.find(cookies[:user_id])
    shows = BetaseriesConnector.get_episodes(@user.betaseries_token)
    teams = [ ["LOL"], ["KILLERS"], ["IMMERSE", "IMM"], ["DIMENSION","DIM"], ["WEB-DL"], ["2HD"], ["ASAP"]]

    @tv_shows = Array.new
    shows.each do |s|
      logger.info 'Fill with beta series'
      t = TvShowFactory.create_tv_show(s, 2, @user.betaseries_token)
      logger.info t.to_yaml
      t.save!
      @tv_shows.push(t)
    end

    if @user.tv_shows.nil?
      @user.tv_shows = Array.new
    end

    @tv_shows.each do |tv_show|
      tv_show.save!
      logger.info  'Collections :'
      @user.tv_shows.push(tv_show)

      tv_show.episodes.each do |episode|
        EpisodeFactory.fetch_subtitles_available(episode, @user.betaseries_token, teams)
        episode.find_torrent(true, @freebox.session_token)
      end
    end
  end

  def pick_torrent
  end

end
