require "uri"
require "net/http"

CONJUR_HOST = "conjur.home.huydo.net"
CONJUR_ACCOUNT = "DEMO"
CONJUR_USER_ID = "testuser01@test"
CONJUR_USER_KEY = "1x1hh0f211c133nzbt6d25v50vrtzyvkm86mzm81h89f392gvexx2"
CONJUR_SECRET_PATH = "test/host1/pass"

# Authenticaiton request
url = URI("https://#{CONJUR_HOST}/authn/#{CONJUR_ACCOUNT}/#{CONJUR_USER_ID}/authenticate")
https = Net::HTTP.new(url.host, url.port)
https.use_ssl = true

request = Net::HTTP::Post.new(url)
request["Accept-Encoding"] = "base64"
request["Content-Type"] = "text/plain"
request.body = "#{CONJUR_USER_KEY}"

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

