require_relative '../../lib/betaseries_connector.rb'
require_relative '../../lib/freeboxos_connector'
require_relative '../models/user'

class LoginController < ApplicationController

  def return
    logger.info "call return"
    code = params[:code]

    @user = UserFactory.get_user_by_betaseries_code(code)
    cookies[:user_id] = @user.id
    @freebox = Freebox.find_by_users_id(@user.id)

    if @freebox.nil?
      redirect_to :controller => 'freeboxes', :action => 'attach'
    else
      app_token = @freebox.app_token
      @user.session_token = FreeboxOSConnector.open_session_with_app_token(app_token)
      @user.save
      redirect_to :controller => 'episode', :action => 'update'
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
