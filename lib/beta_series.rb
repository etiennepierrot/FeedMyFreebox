require 'rest_client'
require 'json'

class BetaSeriesConnector
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
    json = client["episodes/list"].get({:'X-BetaSeries-Token' => user_token,:'X-BetaSeries-Version' => 2.2,
                                      :'X-BetaSeries-Key' => @@public_key  })

    return JSON.parse(json)["shows"]
  end

  def get_client()
    return RestClient::Resource.new(@@host)
  end

end

code = ARGV[0]
betaseries_connector = BetaSeriesConnector.new()
user_token = betaseries_connector.get_user_token(code)
shows = betaseries_connector.get_episodes(user_token)

shows.each do |s|
  episode = s["unseen"][0]
  puts  episode["id"].to_s + " - " + s["title"] + " - " + episode["code"] + " _ " + episode["title"]
end

#shows.each{|e| puts  e["unseen"][0]["title"] }













