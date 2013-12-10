require 'rubygems'
require 'zip/zip'
require 'net/http'
require 'open-uri'

module SubtitleUnzipper



  def self.get_distant_path(url_path, file_name)
    path_file = "C:\\srt\\#{file_name}"
    puts path_file
    if !File.exist?(path_file)
      url_path["https://"] = "http://" unless !url_path.include?("https://")
      open(path_file, 'wb') do |file|
        file << open(url_path).read
      end
    end
    return path_file

    #

    #
    #path_file = "#{srt_directory}\\#{file_name}"
    #
    #if !File.exist?(path_file)
    #  File.open("C:\\srt\\#{file_name}", "wb") do |file|
    #
    #    url_path["https://"] = "http://" unless !url_path.include?("https://")
    #    puts url_path
    #    file.write open(path_file).read
    #  end
    #end
    #

  end

  def self.unzip_file (file)
    files = Array.new
    Zip::ZipFile.open(file) { |zip_file|
      zip_file.each { |f|
        f_path=File.join(File.dirname(file), f.name)
        files.push(f.name)
        zip_file.extract(f, f_path) unless File.exist?(f_path)
      }
    }
    return files
  end

  def self.UnzipData(file_name)

    subtitles = Array.new
   puts file_name
    zf =Zip::File.open(file_name, Zip::File::CREATE)
    #zf = ZipFile.new(file_name)
    zf.each_with_index {
        |entry, index|
      hash = Hash.new
      hash["file"] = entry.name
      #zf.get_input_stream(entry)
      #subtitle_new = Subtitle.new(hash)
      #subtitles.push subtitle_new
      f_path=File.join("srt", zf.name)
      puts zf.name
      FileUtils.mkdir_p(File.dirname(f_path))
      zip_file.extract(zf, f_path) unless File.exist?(f_path)

      #puts "entry #{index} is #{entry.name}, size = #{entry.size}, compressed size = #{entry.compressed_size}"
      # use zf.get_input_stream(entry) to get a ZipInputStream for the entry
      # entry can be the ZipEntry object or any object which has a to_s method that
      # returns the name of the entry.
    }

    return subtitles

  end
end


SubtitleUnzipper.get_distant_path("http://www.betaseries.com/srt/438085", "test")

