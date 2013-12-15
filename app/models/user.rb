class User < ActiveRecord::Base
  has_many :freeboxes, :foreign_key  => 'users_id', :autosave => 'true'
  has_many :followers
  has_many :tv_shows, through: :followers
  attr_accessible :betaseries_id, :betaseries_login, :betaseries_token
end
