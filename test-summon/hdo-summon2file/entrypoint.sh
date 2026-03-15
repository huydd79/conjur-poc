#!/bin/bash

# Ensure required common variables are set
export CONJUR_APPLIANCE_URL="${CONJUR_APPLIANCE_URL}"
export CONJUR_ACCOUNT="${CONJUR_ACCOUNT}"
export CONJUR_CERT_FILE="/app/conjur-server.pem"

# 1. Automatic Certificate Fetching
if [ ! -f "$CONJUR_CERT_FILE" ]; then
    echo "Fetching Conjur certificate..."
    HOST=$(echo $CONJUR_APPLIANCE_URL | awk -F[/:] '{print $4}')
    PORT=$(echo $CONJUR_APPLIANCE_URL | awk -F[/:] '{print $5}')
    openssl s_client -showcerts -connect "$HOST:$PORT" < /dev/null 2> /dev/null | \
    sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "$CONJUR_CERT_FILE"
fi

# 2. Determine Authentication Method
if [ "$AUTH_METHOD" == "jwt" ]; then
    echo "Configuring Summon for JWT authentication..."
    export CONJUR_AUTHN_JWT_SERVICE_ID="$JWT_SERVICE_ID"
    export JWT_TOKEN_PATH="/app/jwt_token"
    export CONJUR_AUTHN_LOGIN="host/$JWT_HOST_ID"
    # Ensure JWT token is present
    if [ ! -s "/app/jwt_token" ]; then echo "Error: /app/jwt_token is empty"; exit 1; fi
else
    echo "Configuring Summon for API Key authentication..."
    export CONJUR_AUTHN_LOGIN="$CONJUR_USER"
    export CONJUR_AUTHN_API_KEY="$CONJUR_API_KEY"
fi

# 3. Run Summon
# Maps Conjur variable $VARIABLE_PATH to environment variable $PASSWORD
summon --yaml "PASSWORD: !var $VARIABLE_PATH" /app/test.sh

echo "Press enter to exit..."
read
