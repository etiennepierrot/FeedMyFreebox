class Subtitle < ActiveRecord::Base
  belongs_to :episode
  attr_accessible :path, :file, :language, :betaseries_id
end