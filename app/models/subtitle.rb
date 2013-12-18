class Subtitle < ActiveRecord::Base
  belongs_to :episode
  belongs_to :team
  attr_accessible :path, :file, :language, :betaseries_id

  def name
    return path
  end

end