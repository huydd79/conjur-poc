#!/bin/bash

source ../00.config.sh
if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

source ./00.config.sh

if [ ! -f "$JWT_FILE" ]; then
    echo "Please generate jwt file before running this script"
    exit
fi

CONJUR_URL="https://$CONJUR_IP:$POC_CONJUR_HTTPS_PORT"

JWT=$(cat $JWT_FILE)

echo "Sending authentication request and get secret..."
CONJUR_VAR_PASSWORD="test/host1/pass"
set -x

AUTH_TOKEN=$(curl -sk -X POST $CONJUR_URL/authn-jwt/$JWT_SERVICE_ID/$POC_CONJUR_ACCOUNT/authenticate \
		  --data-raw "jwt=$JWT" | base64 -w 0)

PASSWORD=$(curl -sk --request GET $CONJUR_URL/secrets/$POC_CONJUR_ACCOUNT/variable/$CONJUR_VAR_PASSWORD \
                --header "Authorization: Token token=\"$AUTH_TOKEN\"")
echo $PASSWORD
set +x
