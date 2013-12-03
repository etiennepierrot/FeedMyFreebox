require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'transmission_api'

class Episode
  attr_reader :title, :seed, :url
   def initialize(title, seed, url)
     @title = title
     @seed = seed
     @url = url
   end
end

def request_torrent(request)
  encoded_request = URI::encode(request)
  urlPath = "http://kickass.to/usearch/#{encoded_request}/?rss=1"
  url = URI.parse(urlPath)
  res = Net::HTTP.get_response(url)
  return res.body
end

def parse_list_episode(xml_string)
  doc = Nokogiri::XML(xml_string)
  items = Array.new

  doc.xpath('//item').each do |thing|
    title = thing.at_xpath('title').content
    seeds = thing.at_xpath('torrent:seeds').content
    url = thing.at_xpath('torrent:magnetURI').content
    item = Episode.new(title, seeds, url)
    items.push item
    puts item.title
  end
  return items
end

def get_best_choice(episodes, teams)
  episodes.select!{|i| teams.any?{|t| i.title.include?(t) }}
  best_choice = episodes.max_by(&:seed)
  return best_choice
end

def send_to_freebox(episode, password)
  transmission_api =
      TransmissionApi.new(
          :username => "freebox",
          :password => password,
          :url      => "http://mafreebox.freebox.fr:9091/transmission/rpc"
      )

  torrent = transmission_api.create(episode.url)
end

request = ARGV[0]
password = ARGV[1]


teams = ["LOL", "KILLERS", "IMMERSE"]
xml_string = request_torrent(request)
items = parse_list_episode(xml_string)
best_choice = get_best_choice(items, teams)
puts "Title : " + best_choice.title
puts "Seeds : " + best_choice.seed
puts "Url : " + best_choice.url

send_to_freebox(best_choice, password)







