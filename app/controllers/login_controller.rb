require_relative '../../lib/betaseries_connector.rb'
require_relative '../models/user'

class LoginController < ApplicationController

  def return
    logger.info "call return"
    code = params[:code]

    betaseries_user = BetaseriesConnector.get_user(code)

    login = betaseries_user['user']['login']
    betaseries_id = betaseries_user['user']['id']
    @user = User.find_by_betaseries_id(betaseries_id)

    if @user.nil?
      @user = User.new()
      @user.betaseries_id = betaseries_id
      @user.betaseries_login = login
    end

    @user.betaseries_token = betaseries_user['token']
    @user.save
    cookies[:user_id] = @user.id
    logger.info @user.to_yaml

    @freebox = Freebox.find_by_users_id(@user.id)
    logger.info @freebox.to_yaml
    challenge =FreeboxOSConnector.get_challenge
    password = FreeboxOSConnector.create_password(@freebox.app_token, challenge)
    @freebox.session_token = FreeboxOSConnector.open_session(password)['session_token']

    shows = BetaseriesConnector.get_episodes(@user.betaseries_token)
    teams = [ ["LOL"], ["KILLERS"], ["IMMERSE", "IMM"], ["DIMENSION","DIM"], ["WEB-DL"], ["2HD"], ["ASAP"]]

    tv_shows = Array.new
    shows.each do |s|
      logger.info "Fill with beta series"
      t = TvShowFactory.create_tv_show(s, 2, @user.betaseries_token)
      logger.info t.to_yaml
      t.save!
      tv_shows.push(t)
    end



    if @user.tv_shows.nil?
      @user.tv_shows = Array.new
    end

    tv_shows.each do |tv_show|
      tv_show.save!
      logger.info  'Collections :'
      @user.tv_shows.push(tv_show)
      #tv_show.fetch_subtitles_available(@user.betaseries_token, teams)
      #tv_show.episodes.each do |episode|
      #  episode.find_torrent(true, @freebox.session_token)
      #end
    end



  end

  def index
    @login = Login.new
    @login.host = get_url
    @login.key = ENV['betaseries_public_key']
  end

  def get_url
    return "http://#{request.host}:#{request.port}/login/return"
  end
end
