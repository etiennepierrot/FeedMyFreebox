require_relative '../../lib/freeboxos_connector'

class FreeboxesController < ApplicationController

  def attach
    user_id = cookies[:user_id]

    @freebox = Freebox.new
    @freebox.app_name = 'Feed my Freebox'
    @freebox.app_id = 'fr.freebox.feedmyfreebox'
    @freebox.app_version = '0.0.1'
    authorization = FreeboxOSConnector.create_track_authorization(@freebox)
    @freebox.app_token = authorization["app_token"]
    @freebox.track_authorization_id = authorization["track_id"]
    @freebox.users_id = user_id

    logger.info @freebox.to_yaml

    @freebox.save
  end

  def confirm
     @freebox = Freebox.find(params["freebox_id"])

     if @freebox.users_id.to_s != cookies[:user_id]
       raise "It's not your freebox bad guy!!!"
     end

    track_authorization = FreeboxOSConnector.get_track_authorization(@freebox.track_authorization_id)

    if track_authorization['status'] == 'granted'
      challenge =FreeboxOSConnector.get_challenge
      password = FreeboxOSConnector.create_password(@freebox.app_token, challenge)
      @freebox.session_token = FreeboxOSConnector.open_session(password)['session_token']

    else
      @message = "Veuillez authorisez l'application Feed My Freebox sur l'ecran digitale de votre freebox"
    end

    @freebox.save
  end

  def get
    id = params[:id]
    logger.info Freebox.find(id).to_yaml
  end
end
