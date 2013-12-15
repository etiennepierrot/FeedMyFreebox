class CreateSubtitles < ActiveRecord::Migration
  def change
    create_table :subtitles do |t|
      t.string :betaseries_id
      t.string :path
      t.string :language
      t.string :file
      t.belongs_to :episode
      t.timestamps
    end
  end
end
