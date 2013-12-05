require_relative '../app/models/torrent'

def get_best_choice(episodes, teams)
  episodes.select!{|i| teams.any?{|t| i.title.include?(t) }}
  best_choice = episodes.max_by(&:seed)
  return best_choice
end