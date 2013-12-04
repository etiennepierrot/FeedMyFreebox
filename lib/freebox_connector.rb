require 'transmission_api'
require_relative '../app/models/episode'

class FreeboxConnector

  def initialize(password)
    @password = password
  end

  def send(episode)
    torrent = transmission_api.create(episode.url)
  end

  def all()
    return transmission_api.all
  end

  def destroy(id)
    transmission_api.destroy(id)
  end

  def transmission_api()  #static method (known as a class method in ruby)

    transmission_api =
        TransmissionApi.new(
            :username => "freebox",
            :password => @password,
            :url      => "http://mafreebox.freebox.fr:9091/transmission/rpc"
        )

    return transmission_api;
  end
end


