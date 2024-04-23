require "uri"
require "net/http"

CONJUR_HOST = "conjur.home.huydo.net"
CONJUR_ACCOUNT = "DEMO"
CONJUR_SECRET_PATH = "test/host1/pass"
JWT_SERVICE_ID="testjwt"
JWT_FILE="./test.jwt"

# Reading jwt value
JWT = File.read (JWT_FILE)

# Authenticaiton request
url = URI("https://#{CONJUR_HOST}/authn-jwt/#{JWT_SERVICE_ID}/#{CONJUR_ACCOUNT}/authenticate")
https = Net::HTTP.new(url.host, url.port)
https.use_ssl = true

request = Net::HTTP::Post.new(url)
request["Accept-Encoding"] = "base64"
request["Content-Type"] = "text/plain"
request.body = "jwt=#{JWT}"

response = https.request(request)

if response.code != "200"
    puts "Authentication error: " + response.code + " " + response.message
    exit
end

TOKEN = response.read_body
puts "Authn done. TOKEN: " + TOKEN

# Secret retrieving request
url = URI("https://#{CONJUR_HOST}/secrets/#{CONJUR_ACCOUNT}/variable/#{CONJUR_SECRET_PATH}")
https = Net::HTTP.new(url.host, url.port)
https.use_ssl = true

request = Net::HTTP::Get.new(url)
request["Authorization"] = "Token token=\""+TOKEN+"\""

response = https.request(request)

if response.code != "200"
    puts "Secret request error: " + response.code + " " + response.message
    exit
end

SECRET = response.read_body
puts "SECRET: " + SECRET

