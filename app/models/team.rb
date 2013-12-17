class Team < ActiveRecord::Base
  attr_accessible :name, :tag

  def get_teams_tag
    return tag.split(';')
  end

end
