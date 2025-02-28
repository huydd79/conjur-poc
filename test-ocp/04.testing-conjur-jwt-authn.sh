#!/bin/bash

set -x
JWT=$(cat test.jwt)

SESSIONTOKEN=$(curl -k -X POST https://conjur.home.huydo.net:8443/authn-jwt/ocp/DEMO/authenticate -H "Content-Type: application/x-www-form-urlencoded" -H "Accept-Encoding: base64" --data-urlencode "jwt=$JWT")
echo "======== TEST RESULT ======="
echo $SESSIONTOKEN
set +x
