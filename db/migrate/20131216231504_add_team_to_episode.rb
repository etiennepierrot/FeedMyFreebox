class AddTeamToEpisode < ActiveRecord::Migration
  def change
    alter_table :subtitles do |s|
      s.belongs_to :team
    end
  end
end
