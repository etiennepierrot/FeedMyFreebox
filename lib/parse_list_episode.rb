require 'nokogiri'
require_relative '../app/models/episode'

def parse_list_episode(xml_string)
  doc = Nokogiri::XML(xml_string)
  items = Array.new

  doc.xpath('//item').each do |thing|
    title = thing.at_xpath('title').content
    seeds = thing.at_xpath('torrent:seeds').content
    url = thing.at_xpath('torrent:magnetURI').content
    item = Episode.new(title, seeds, url)
    items.push item
  end
  return items
end