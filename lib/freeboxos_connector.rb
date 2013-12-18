# encoding: utf-8
require 'rest_client'
require 'json'
require 'base64'
require 'cgi'
require 'hmac-sha1'
require 'openssl'
require 'net/http/post/multipart'
require 'fileutils'
require_relative '../app/models/freebox'

module FreeboxOSConnector
  @@app_id = "fr.freebox.feedmyfreebox"
  @@client = RestClient::Resource.new("http://82.240.165.61/")
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
      puts "une erreur s'est produite pendant l'authorization"
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

  def self.create_track_authorization(freebox)

    params = {
        "app_id" => freebox.app_id,
        "app_name" =>  freebox.app_name,
        "app_version" =>  freebox.app_version,
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

  def self.upload_file(session_token, parent, filename_original, new_filename )
    params = {
        "dirname" => parent,
        "upload_name" => new_filename
    }
    json = @@discover_client["upload/"].post(params.to_json, get_session_header(session_token))

    response_upload = get_response(json)

    if !response_upload.nil?
      puts "send file!!!!"

      upload_id = response_upload["id"]

      url = URI.parse("http://mafreebox.freebox.fr/api/v1/upload/#{upload_id}/send")
      Rails.logger.info filename_original
      File.open(filename_original) do |file|
        req = Net::HTTP::Post::Multipart.new url.path,
                                             {"file" => UploadIO.new(file, "text/plain", new_filename),
                                              'X-Fbx-App-Auth' => session_token}
        res = Net::HTTP.start(url.host, url.port) do |http|
          puts http.request(req)
        end
        puts res
      end
    end
  end

  def self.open_session_with_app_token(app_token)
    challenge = get_challenge
    password = create_password(app_token, challenge)
    return open_session(password)['session_token']
  end

end





#FreeboxOSConnector.initialize
#
#freebox = Freebox.new
#freebox.app_name = 'Feed my Freebox'
#freebox.app_id = 'fr.freebox.feedmyfreebox'
#freebox.app_version = '0.0.1'
#puts FreeboxOSConnector.create_track_authorization freebox
#track_id = 22
#app_token = "A88Cudkvct00J1FOpU1rRIKBrmrKW0X44IMx31guVaGCqJGHgS1uTNpE+ZstT+OT"
##track_authorization = FreeboxOSConnector.get_track_authorization(track_id)
#challenge =FreeboxOSConnector.get_challenge
#password = FreeboxOSConnector.create_password(app_token, challenge)
#session_token = FreeboxOSConnector.open_session(password)['session_token']
#
#
#puts session_token
#tv_show_name = 'The Walking Dead'
#code = 'S04E05'

#
#
#
#FreeboxOSConnector.make_directory( session_token, videos_directory, tv_show_name ) #
#list_video_directory = FreeboxOSConnector.list_directory(session_token, videos_directory)
#directory = list_video_directory.select{ |f| f["name"] == tv_show_name and f["mimetype"] == "inode/directory"}[0]
#tv_show_directory =  directory["path"]
#
#FreeboxOSConnector.create_download(session_token, "magnet:?xt=urn:btih:A6D390133B2AE10926C48EB120E60662FE195C28&dn=the+walking+dead+s04e05+vostfr+gillop+avi&tr=udp%3A%2F%2Ftracker.istole.it%3A80%2Fannounce&tr=udp%3A%2F%2Fopen.demonii.com%3A1337", tv_show_directory)
#send_subtitle_with_movie(tv_show_directory, "#{tv_show_name} #{code}", "Borgen.S01E10.720p.BluRay.x264.anoXmous_swe.srt", session_token)
#
#
#FreeboxOSConnector.initialize
#
#freebox = Freebox.new
#freebox.app_name = 'Feed my Freebox'
#freebox.app_id = 'fr.freebox.feedmyfreebox'
#freebox.app_version = '0.0.1'
#puts FreeboxOSConnector.create_track_authorization freebox
#track_id = 22
#app_token = "A88Cudkvct00J1FOpU1rRIKBrmrKW0X44IMx31guVaGCqJGHgS1uTNpE+ZstT+OT"
##track_authorization = FreeboxOSConnector.get_track_authorization(track_id)
#challenge =FreeboxOSConnector.get_challenge
#password = FreeboxOSConnector.create_password(app_token, challenge)
#session_token = FreeboxOSConnector.open_session(password)['session_token']
#
#
#puts session_token
#tv_show_name = 'The Walking Dead'
#code = 'S04E05'
#videos_directory = "L0Rpc3F1ZSBkdXIvVmlkw6lvcw=="
#
#
#
#FreeboxOSConnector.make_directory( session_token, videos_directory, tv_show_name ) #
#list_video_directory = FreeboxOSConnector.list_directory(session_token, videos_directory)
#directory = list_video_directory.select{ |f| f["name"] == tv_show_name and f["mimetype"] == "inode/directory"}[0]
#tv_show_directory =  directory["path"]
#
#FreeboxOSConnector.create_download(session_token, "magnet:?xt=urn:btih:A6D390133B2AE10926C48EB120E60662FE195C28&dn=the+walking+dead+s04e05+vostfr+gillop+avi&tr=udp%3A%2F%2Ftracker.istole.it%3A80%2Fannounce&tr=udp%3A%2F%2Fopen.demonii.com%3A1337", tv_show_directory)
#send_subtitle_with_movie(tv_show_directory, "#{tv_show_name} #{code}", "Borgen.S01E10.720p.BluRay.x264.anoXmous_swe.srt", session_token)
#
#




#download_id = 33
#download_response = FreeboxOSConnector.get_download(session_token, download_id)
#status = download_response["status"]
#
#if status == 'seeding'
#  FreeboxOSConnector.stop_download(session_token, download_id)["status"]
#end





#puts FreeboxOSConnector.get_challenge

