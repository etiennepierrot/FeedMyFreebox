require 'rest_client'

public_key = ARGV[0]
private_key = ARGV[1]
code = ARGV[2]

betaseries_host = "http://api.betaseries.com"
member_accesstoken = "members/access_token"


url = 'http://localhost:3000/return'


puts ENV['betaseries_public_key']

param = {"client_id" => public_key, "client_secret" => private_key, "redirect_uri" => url, "code" => code }
body = URI.encode_www_form(param)
ressource =  "#{betaseries_host}/#{member_accesstoken}"
puts ressource
puts body





RestClient.post(
    ressource,
    body,
    :'X-BetaSeries-Key' => public_key,
    :'Content-Type' => 'application/x-www-form-urlencoded')










