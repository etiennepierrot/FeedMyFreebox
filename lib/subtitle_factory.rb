module SubtitleFactory

  def self.create_subtitle(hash_subtitle)

    subtitles = Subtitle.find_all_by_betaseries_id(hash_subtitle['id'])
    Rails.logger.info "Subtitle object :"
    Rails.logger.info subtitles.length.to_s
    if subtitles.nil? or subtitles.length == 0

      subtitles = Array.new

      if hash_subtitle['file'].end_with?('.srt')

        subtitle = Subtitle.new
        subtitle.betaseries_id = hash_subtitle['id']
        subtitle.file = hash_subtitle["file"]
        subtitle.language = hash_subtitle["language"]
        subtitle.path =  SubtitleUnzipper.get_distant_path(hash_subtitle['url'], hash_subtitle['file'])
        subtitles.push subtitle
      else
        if hash_subtitle['file'].include?('zip')
          data = SubtitleUnzipper.get_distant_path(hash_subtitle['url'], hash_subtitle['file'])
          files = SubtitleUnzipper.unzip_file(data)
          files.each do |f|
            subtitle = Subtitle.new
            subtitle.path = "C:\\srt\\" + f
            subtitle.betaseries_id = hash_subtitle['id']
            subtitles.push subtitle
          end
        end
      end
    end

    return subtitles
  end
end