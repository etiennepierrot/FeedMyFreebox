# encoding: utf-8
require 'rest_client'
require 'json'
require 'base64'
require 'cgi'
require 'hmac-sha1'
require 'openssl'


module FreeboxOSConnector
  @@app_id = "fr.freebox.feedmyfreebox"
  @@client = RestClient::Resource.new("http://mafreebox.freebox.fr")
  @@FreeboxHeader = "X-Fbx-App-Auth"
  @@discover_client
  @@api_base_url
  @@version



  def self.get_session_header(session_token)
    return {'X-Fbx-App-Auth' => session_token}
  end

  def self.create_password(app_token, challenge)
    return OpenSSL::HMAC.hexdigest('sha1', app_token, challenge)
  end


  def self.get_response(response_json)
    json = JSON.parse(response_json)
    if json["success"]
      return json["result"]
    else
      puts json
      raise "une erreur s'est produite pendant l'authorization"
    end
  end
  def self.initialize
    json = @@client["api_version"].get()
    json_parse = JSON.parse(json)
    @@api_base_url = json_parse["api_base_url"]
    version = json_parse["api_version"].split('.')
    @@version = "v" + version[0]
    @@discover_client = RestClient::Resource.new("http://mafreebox.freebox.fr#{@@api_base_url}#{@@version}")
  end

  def self.create_track_authorization

    params = {
        "app_id" => @@app_id,
        "app_name" => "Feed My Freebox",
        "app_version" => "0.0.1",
        "device_name" =>  Socket.gethostname
    }

    json = @@discover_client["login/authorize"].post(params.to_json)
    response = get_response(json)
    return response
  end

  def self.get_track_authorization(track_id)
    json = @@discover_client["login/authorize/#{track_id}"].get()
    return get_response(json)
  end

  def self.get_challenge
    json = @@discover_client["login"].get()
    return get_response(json)["challenge"]
  end

  def self.open_session(password)
    params = {
        "app_id" => @@app_id,
        "password" => password
    }
    json = @@discover_client["login/session"].post(params.to_json)
    return get_response(json)
  end


  def self.create_download(session_token, download_url, directory)
    params = {
        :download_url => download_url,
        :download_dir => directory
    }
    body = URI.encode_www_form(params)

    return @@discover_client['downloads/add'].post(body, get_session_header(session_token))
  end


  def self.get_download(session_token, download_id)
    json = @@discover_client["downloads/#{download_id}"].get(get_session_header(session_token))
    return get_response(json)
  end

  def self.stop_download(session_token, download_id)
    json = @@discover_client["downloads/#{download_id}"].put({:status => "stopped"}.to_json, get_session_header(session_token))
    return get_response(json)
  end

  def self.list_directory(session_token, directory)
    json = @@discover_client["fs/ls/#{directory}"].get(get_session_header(session_token))
    return get_response(json)
  end

  def self.make_directory(session_token, parent, directory)
    params = {
        "parent" => parent,
        "dirname" => directory
    }
    @@discover_client["fs/mkdir"].post(params.to_json, get_session_header(session_token))
  end




end

FreeboxOSConnector.initialize
#puts FreeboxOSConnector.create_track_authorization
track_id = 22
app_token = "A88Cudkvct00J1FOpU1rRIKBrmrKW0X44IMx31guVaGCqJGHgS1uTNpE+ZstT+OT"
#track_authorization = FreeboxOSConnector.get_track_authorization(track_id)
challenge =FreeboxOSConnector.get_challenge
password = FreeboxOSConnector.create_password(app_token, challenge)
session_token = FreeboxOSConnector.open_session(password)['session_token']

tv_show_name = 'The Walking Dead'
videos_directory = "L0Rpc3F1ZSBkdXIvVmlkw6lvcw=="

FreeboxOSConnector.make_directory( session_token, videos_directory, tv_show_name )
list_video_directory = FreeboxOSConnector.list_directory(session_token, videos_directory)
directory = list_video_directory.select{ |f| f["name"] == tv_show_name and f["mimetype"] == "inode/directory"}[0]
FreeboxOSConnector.create_download(session_token, "magnet:?xt=urn:btih:A6D390133B2AE10926C48EB120E60662FE195C28&dn=the+walking+dead+s04e05+vostfr+gillop+avi&tr=udp%3A%2F%2Ftracker.istole.it%3A80%2Fannounce&tr=udp%3A%2F%2Fopen.demonii.com%3A1337", directory["path"])

download_id = 33
download_response = FreeboxOSConnector.get_download(session_token, download_id)
status = download_response["status"]

if status == 'seeding'
  FreeboxOSConnector.stop_download(session_token, download_id)["status"]
end



def is_movie(filename, moviename)
  extensions = [".mp4", ".mkv", ".avi"]
  isMovie = !extensions.any?{ |e| filename.end_with?(e)}
  if isMovie
    splited_name = moviename.split(' ')
    splited_name.each do |s|
      if !filename.include?(s)
        return false
      end
    end
    return true
  else
     return false
  end
end


#puts FreeboxOSConnector.get_challenge
