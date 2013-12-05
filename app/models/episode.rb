class Episode

  def initialize(episode_hash)
    @episode_hash = episode_hash
  end

  def id
    return @episode_hash["id"]
  end

end