#!/bin/bash
# Pre-requisite: Run test-auth-jwt scripts to ensure JWT is configured and valid

source ../00.config.sh
source ../test-authn-jwt/00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration is not ready. Set READY=true in 00.config.sh"
    exit 1
fi

JWT_TOKEN_PATH="../test-authn-jwt/data/jwt"

if [ ! -f "$JWT_TOKEN_PATH" ]; then
    echo "Error: JWT token file not found at $JWT_TOKEN_PATH."
    exit 1
fi

# Conjur Connection Settings
export CONJUR_APPLIANCE_URL="https://conjur.$POC_DOMAIN:$POC_CONJUR_HTTPS_PORT"
export CONJUR_ACCOUNT="CYBR"
export CONJUR_CERT_FILE="./conjur-server.pem"
# --- Certificate Generation Logic ---
if [ ! -f "$CONJUR_CERT_FILE" ]; then
    echo "Certificate $CONJUR_CERT_FILE not found. Fetching from $CONJUR_APPLIANCE_URL..."
    
    # Extract the hostname and port from the URL
    HOST=$(echo $CONJUR_APPLIANCE_URL | awk -F[/:] '{print $4}')
    PORT=$(echo $CONJUR_APPLIANCE_URL | awk -F[/:] '{print $5}')
    
    # Use openssl to fetch the certificate
    openssl s_client -showcerts -connect "$HOST:$PORT" < /dev/null 2> /dev/null | \
    sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "$CONJUR_CERT_FILE"
    
    if [ -s "$CONJUR_CERT_FILE" ]; then
        echo "Successfully created $CONJUR_CERT_FILE"
    else
        echo "Error: Failed to fetch certificate. Please check your Conjur URL or network connection."
        exit 1
    fi
fi
# ------------------------------------

# JWT Authenticator Settings
# Note: Summon uses CONJUR_AUTHN_URL as the base for the authentication request
export CONJUR_AUTHN_URL="$CONJUR_APPLIANCE_URL/authn-jwt/$JWT_SERVICE_ID"

# MANDATORY: Use CONJUR_JWT_TOKEN_PATH for raw JWT authentication
# This tells Summon: "Take this JWT, exchange it for a Conjur token, then fetch secrets"
export CONJUR_JWT_TOKEN_PATH="$JWT_TOKEN_PATH"

# Define the identity that matches the 'host' claim in your JWT
export CONJUR_AUTHN_LOGIN="host/$JWT_HOST_ID"

# Clear this variable to ensure it doesn't conflict with JWT logic
unset CONJUR_AUTHN_TOKEN_FILE

set -x

# Execute Summon
# It will now automatically handle the POST request to the authn-jwt endpoint
summon --yaml "PASSWORD: !var test/host1/pass" ./test.sh

set +x