import http.client

CONJUR_HOST="conjur.home.huydo.net"
CONJUR_ACCOUNT="DEMO"
CONJUR_USER_ID="testuser01@test"
CONJUR_USER_KEY="1x1hh0f211c133nzbt6d25v50vrtzyvkm86mzm81h89f392gvexx2"
CONJUR_SECRET_PATH="test/host1/pass"

conn = http.client.HTTPSConnection(CONJUR_HOST)
request = f"/authn/{CONJUR_ACCOUNT}/{CONJUR_USER_ID}/authenticate"
headers = {
  'Accept-Encoding': 'base64',
  'Content-Type': 'text/plain'
}

conn.request("POST", request, CONJUR_USER_KEY, headers)
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


