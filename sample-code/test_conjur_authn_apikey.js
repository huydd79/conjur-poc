var request = require('request');
var CONJUR_HOST="conjur.home.huydo.net"
var CONJUR_ACCOUNT="DEMO"
var CONJUR_USER_ID="testuser01@test"
var CONJUR_USER_KEY="1x1hh0f211c133nzbt6d25v50vrtzyvkm86mzm81h89f392gvexx2"
var CONJUR_SECRET_PATH="test/host1/pass"

// Accepting self-signed certs. Please remove this setting on production env
process.env["NODE_TLS_REJECT_UNAUTHORIZED"] = 0;

function doRequest(data) {
  return new Promise(function (resolve, reject) {
    request(data, function (error, res, body) {
      if (error) throw new Error(error);
      if (res.statusCode === 200) {
        resolve(body);
      } else {
        reject(res.statusCode);
      }
    });
  });
}

async function main() {
  // Preparing for authentication request
  var options = {
    'method': 'POST',
    'url': `https://${CONJUR_HOST}/authn/${CONJUR_ACCOUNT}/${CONJUR_USER_ID}/authenticate`,
    'headers': {
      'Accept-Encoding': 'base64',
      'Content-Type': 'text/plain'
    },
    body: `${CONJUR_USER_KEY}`

  };
  var TOKEN="";
  try {
    TOKEN = await doRequest (options);
    console.log (`TOKEN: ${TOKEN}`);
  } catch (error) {
    console.error("Authentication error:", error);
    return;
  }

  // Preparing for secret retrieving request
  options = {
    'method': 'GET',
    'url': `https://${CONJUR_HOST}/secrets/${CONJUR_ACCOUNT}/variable/${CONJUR_SECRET_PATH}`,
    'headers': {
      'Authorization': `Token token="${TOKEN}"`
    }
  };

  try {
    SECRET = await doRequest (options);
    console.log (`SECRET: ${SECRET}`);
  } catch (error) {
    console.error("Secret request error:", error);
  }

}

main()
