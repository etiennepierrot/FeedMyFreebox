class LoginController < ApplicationController

  def return
    code = params[:code]

  end

  def index
    @login = Login.new(get_url, ENV['betaseries_public_key'])
  end

  def get_url
    return "http://#{request.host}:#{request.port}/login/return"
  end
end
