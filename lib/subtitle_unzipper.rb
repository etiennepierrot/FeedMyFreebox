require 'rubygems'
require 'zip/zip'
require 'net/http'
require 'open-uri'

module SubtitleUnzipper



  def self.get_distant_path(url_path, file_name)
    path_file = "C:\\srt\\#{file_name}"
    path_file['?'] = '' unless !path_file.include?('?')
    puts path_file
    if !File.exist?(path_file)
      url_path["https://"] = "http://" unless !url_path.include?("https://")
      open(path_file, 'wb') do |file|
        file << open(url_path).read
      end
    end
    return path_file

  end

  def self.unzip_file (file)
    files = Array.new
    Zip::ZipFile.open(file) { |zip_file|
      zip_file.each { |f|
        Rails.logger.info "File to extract : " + f.name
        #f.name['?'] = ''
        Rails.logger.info "File to extract : " + f.name
        f_path = File.join(File.dirname(file), f.name)
        Rails.logger.info "File to extract : " + f_path
        files.push(f.name)
        f_path['?'] = '' if f_path.include?('?  ')
        zip_file.extract(f, f_path) unless File.exist?(f_path)
      }
    }
    return files
  end

end


SubtitleUnzipper.get_distant_path("http://www.betaseries.com/srt/438085", "test")

