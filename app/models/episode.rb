class Episode
  attr_reader :title, :seed, :url
  def initialize(title, seed, url)
    @title = title
    @seed = seed
    @url = url
  end
end