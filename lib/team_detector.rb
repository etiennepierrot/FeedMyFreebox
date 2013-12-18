module TeamDetector
  def self.find_team(object_with_team)
    #Rails.logger.info subtitle.to_yaml
    teams = Team.find(:all)
    teams.each do |t|
      tags = t.get_teams_tag
      tags.each do |tag|
        if object_with_team.name.downcase.include?(tag.downcase)
          object_with_team.team = t
        end
      end
    end
  end
end