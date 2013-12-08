class User < ActiveRecord::Base
  has_many :freeboxes, :foreign_key  => 'users_id', :autosave => 'true'
  attr_accessible :betaseries_id, :betaseries_login, :betaseries_token
end
