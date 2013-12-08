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
