class EpisodeController < ApplicationController
  def update
    @user = User.find(cookies[:user_id])
    shows = BetaseriesConnector.get_episodes(@user.betaseries_token)

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
      @user.tv_shows.push(tv_show) unless @user.tv_shows.include?(tv_show)
      @user.save!
    end

  end

  def pick_torrent
    @user = User.find(cookies[:user_id])
    @user.tv_shows.each do |t|
      t.episodes.each do |e|

        EpisodeFactory.get_best_torrent(e, true)
        if e.torrent.nil?
          EpisodeFactory.get_best_torrent(e, false)
        end

        unless e.torrent.nil?
          EpisodeFactory.send(@user.session_token, e)
        end
      end
    end
  end

end
