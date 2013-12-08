require_relative 'lib/parse_list_episode'
require_relative 'lib/torrent_selector'
require_relative 'lib/freebox_connector'
require_relative 'lib/torrent_reader'
require_relative 'app/models/torrent'
require 'logger'

class Object
  def to_sb
    return 'no' if [FalseClass, NilClass].include?(self.class)
    return 'yes' if self.class == TrueClass
    self
  end
end


log = Logger.new(STDOUT)
log.level = Logger::WARN

log.debug("CA LOOOOOGGGGGG!!")
request = ARGV[0]
password = ARGV[1]

teams = ["LOL", "KILLERS", "IMMERSE", "DIMENSION", "WEB-DL"]

xml_string = request_torrent(request)
items = parse_list_episode(xml_string)
best_choice = get_best_choice(items, teams)
freebox_connector =  FreeboxConnector.new(password)
freebox_connector.send(best_choice, Base64.encode64("/Disque dur/Musiques/"))

puts "Title : " + best_choice.title
puts "Seeds : " + best_choice.seed
puts "Url : " + best_choice.url

torrents = freebox_connector.all()
puts "Torrent en cours :"
torrents.each { |t| puts t["name"] + "-" + t["isFinished"].to_sb }

torrents.each do |t|
  if t["isFinished"]
    freebox_connector.destroy(t["id"])
  end
end


