require 'transmission_api'
require_relative '../app/models/torrent'

class FreeboxConnector

  def initialize(password)
    @password = password
  end

  def send(episode, download_dir)
    base_encode = Base64.encode64("/Disque dur/Musiques/")
    puts base_encode
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
        TransmissionApi::Client.new(
            :username => "freebox",
            :password => @password,
            :url      => "http://mafreebox.freebox.fr:9091/transmission/rpc",
            :debug_mode => true
        )

    return transmission_api
  end
end


