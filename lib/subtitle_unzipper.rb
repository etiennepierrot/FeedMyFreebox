require 'rubygems'
require 'zip'
require 'net/http'


module SubtitleUnzipper


  def self.GetDistantFile(urlPath, file_name)
    srt_directory = "C:\\srt"
    path_file = "#{srt_directory}\\#{file_name}"
    if !File.exist?(path_file)
      File.open("C:\\srt\\#{file_name}", "wb") do |file|
        urlPath["https://"] = "http://"
        file.write open(urlPath).read
      end
    end

    return path_file
  end

  def self.UnzipData(file_name)

    subtitles = Array.new

    zf =Zip::File.open(file_name, Zip::File::CREATE)
    #zf = ZipFile.new(file_name)
    zf.each_with_index {
        |entry, index|
      hash = Hash.new
      hash["file"] = entry.name
      subtitle_new = Subtitle.new(hash)
      subtitles.push subtitle_new
      #puts "entry #{index} is #{entry.name}, size = #{entry.size}, compressed size = #{entry.compressed_size}"
      # use zf.get_input_stream(entry) to get a ZipInputStream for the entry
      # entry can be the ZipEntry object or any object which has a to_s method that
      # returns the name of the entry.
    }

    return subtitles

  end
end