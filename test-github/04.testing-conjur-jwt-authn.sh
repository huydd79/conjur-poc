#!/bin/bash

set -x
#This for conjur 12.5 only. Copy CA cert to current folder as $jenkins_host.crt
JWT=$(cat github.jwt)

SESSIONTOKEN=$(curl -k -X POST https://conjur.home.huydo.net:8443/authn-jwt/github/DEMO/authenticate -H "Content-Type: application/x-www-form-urlencoded" -H "Accept-Encoding: base64" --data-urlencode "jwt=$JWT")
echo "======== TEST RESULT ======="
echo $SESSIONTOKEN
set +x
