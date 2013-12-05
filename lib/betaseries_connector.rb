require 'rest_client'
require 'json'

class BetaseriesConnector
  @@host = "http://api.betaseries.com"
  @@public_key = ENV['betaseries_public_key']
  @@private_key = ENV['betaseries_private_key']
  @@url = 'http://localhost:3000/login/return'


  def initialize()
    @@public_key
  end

  def get_user_token(code)
    client = get_client
    param = {"client_id" => @@public_key, "client_secret" => @@private_key, "redirect_uri" => @@url, "code" => code }
    body = URI.encode_www_form(param)
    json = client["members/access_token"].post(body,
                                               :'X-BetaSeries-Key' => @@public_key,
                                               :'Content-Type' => 'application/x-www-form-urlencoded')

    return JSON.parse(json)["token"]
  end

  def get_episodes(user_token)
    client = get_client
    headers = get_user_headers(user_token)
    json = client["episodes/list"].get(headers)

    return JSON.parse(json)["shows"]
  end

  def get_subtitles(user_token, episode_id)
    client = get_client
    headers = get_user_headers(user_token)
    json = client["subtitles/episode?id=#{episode_id}"].get(headers)
    return JSON.parse(json)["subtitles"]
  end

  def get_user_headers(user_token)
    return {:'X-BetaSeries-Token' => user_token,:'X-BetaSeries-Version' => 2.2, :'X-BetaSeries-Key' => @@public_key  }
  end

  def get_client()
    return RestClient::Resource.new(@@host)
  end

end