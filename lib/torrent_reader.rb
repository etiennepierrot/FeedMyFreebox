require 'net/http'
require 'open-uri'

def request_torrent(request)
  encoded_request = URI::encode(request)
  urlPath = "http://kickass.to/usearch/#{encoded_request}/?rss=1"
  url = URI.parse(urlPath)
  res = Net::HTTP.get_response(url)
  return res.body
end












