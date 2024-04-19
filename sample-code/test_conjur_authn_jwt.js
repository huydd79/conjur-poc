var fs = require('fs');
var request = require('request');
var CONJUR_HOST="conjur.home.huydo.net"
var CONJUR_ACCOUNT="DEMO"
var CONJUR_SECRET_PATH="test/host1/pass"
var JWT_SERVICE_ID="testjwt"
var JWT_FILE="./test.jwt"

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
  // Reading JWT data from file
  var JWT;
  try {
    JWT = fs.readFileSync(JWT_FILE);
  } catch (error) {
    console.error("Reading file error: ", error);
    return;
  }
  console.log(`JWT: ${JWT}`);

  // Preparing for authentication request
  var options = {
    'method': 'POST',
    'url': `https://${CONJUR_HOST}/authn-jwt/${JWT_SERVICE_ID}/${CONJUR_ACCOUNT}/authenticate`,
    'headers': {
      'Accept-Encoding': 'base64',
      'Content-Type': 'text/plain'
    },
    body: `jwt=${JWT}`
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
