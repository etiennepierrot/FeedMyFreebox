require 'nokogiri'
require_relative '../app/models/torrent'

module TorrentFactory

  def self.parse_list_episode(xml_string, episode)
    doc = Nokogiri::XML(xml_string)

    if episode.torrents.nil?
      episode.torrents = Array.new
    end

    doc.xpath('//item').each do |thing|

      title = thing.at_xpath('title').content
      not_in_list = !episode.torrents.any?{ |i| i.title == title}

      if not_in_list
        item = Torrent.new
        item.title = title
        item.seed = thing.at_xpath('torrent:seeds').content
        item.url = thing.at_xpath('torrent:magnetURI').content
        item.isHD = item.title.include?('720p')
        item.torrent_file_url = thing.at_xpath('enclosure').attr('url')
        TeamDetector.find_team(item)
        episode.torrents.push item
      end

    end

  end

  def self.request_torrent(request)
    encoded_request = URI::encode(request)
    urlPath = "http://kickass.to/usearch/#{encoded_request}/?rss=1"
    url = URI.parse(urlPath)
    res = Net::HTTP.get_response(url)
    return res.body
  end

  def self.find_torrent(episode)

    result_hd_only = request_torrent( episode.code + ' ' +  episode.tv_show_name + ' 720p')
    parse_list_episode(result_hd_only, episode)

    all_result = request_torrent( episode.code + ' ' + episode.tv_show_name)
    parse_list_episode(all_result, episode)

  end
end