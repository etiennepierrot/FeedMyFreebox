require 'transmission_api'
require_relative '../app/models/episode'

def send_to_freebox(episode, password)
  transmission_api =
      TransmissionApi.new(
          :username => "freebox",
          :password => password,
          :url      => "http://mafreebox.freebox.fr:9091/transmission/rpc"
      )

  torrent = transmission_api.create(episode.url)
end