require_relative 'lib/parse_list_episode'
require_relative 'lib/torrent_selector'
require_relative 'lib/freebox_sender'
require_relative 'lib/torrent_reader'
require_relative 'app/models/episode'

request = ARGV[0]
password = ARGV[1]

teams = ["LOL", "KILLERS", "IMMERSE", "DIMENSION"]

xml_string = request_torrent(request)
items = parse_list_episode(xml_string)
best_choice = get_best_choice(items, teams)
send_to_freebox(best_choice, password)

puts "Title : " + best_choice.title
puts "Seeds : " + best_choice.seed
puts "Url : " + best_choice.url