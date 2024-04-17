import http.client

CONJUR_HOST="conjur.home.huydo.net"
CONJUR_ACCOUNT="DEMO"
CONJUR_SECRET_PATH="test/host1/pass"
JWT_SERVICE_ID="testjwt"
JWT_FILE="./test.jwt"

with open(JWT_FILE,'r') as file:
    JWT = " ".join(line.rstrip() for line in file)
    print("JWT:", JWT)
    
conn = http.client.HTTPSConnection(CONJUR_HOST)
request = f"/authn-jwt/{JWT_SERVICE_ID}/{CONJUR_ACCOUNT}/authenticate"
headers = {
  'Accept-Encoding': 'base64',
  'Content-Type': 'text/plain'
}
body = f"jwt={JWT}"

conn.request("POST", request, body, headers)
res = conn.getresponse()
if res.status != 200:
  print ("Authentication failed. Status:", res.status, res.reason)
  exit (1)

print(f"Status: {res.status}")
print(f"Reason: {res.reason}")
TOKEN = res.read().decode('ASCII')
print("Access Token: ",TOKEN)

request = f"/secrets/{CONJUR_ACCOUNT}/variable/{CONJUR_SECRET_PATH}"
headers = {
    'Authorization': f"Token token=\"{TOKEN}\""
}
conn.request("GET", request, None, headers)
res = conn.getresponse()
data = res.read()
print("Serect: ", data.decode("utf-8"))


