module TvShowFactory

  def self.create_tv_show( hash_show, nb_episode_max, user_token)
    puts 'fill attributes'

    t = TvShow.find_by_betaseries_id(hash_show['id'])
    if t.nil?
      t = TvShow.new
      t.betaseries_id = hash_show['id']
      t.title = hash_show['title']
      t.episodes = Array.new
    end

    hash_show['unseen'][0..nb_episode_max].each do |hash_episode|
      episode = EpisodeFactory.create_episode(hash_episode, t.title, user_token)
      episode.save!
      t.episodes.push(episode)
    end

    t.save!
    return t
  end
end

