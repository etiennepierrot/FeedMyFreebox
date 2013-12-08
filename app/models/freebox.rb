class Freebox < ActiveRecord::Base
  belongs_to :user, :foreign_key  => 'users_id', :autosave => 'true'
  attr_accessible :app_id, :app_name, :app_token, :app_version, :track_authorization_id, :session_token
end
