class Subtitle
  attr_accessor :url, :file, :language

  def initialize(hash_subtitle)
    @url = hash_subtitle["url"]
    @file = hash_subtitle["file"]
    @language = hash_subtitle["language"]
  end

end