#!/bin/bash
# Script to test hdo-summon2file with both API Key and JWT

IMAGE_NAME="hdo-summon2file"
PUBLIC_KEY_PATH="$(pwd)/test_data/public_key.pem"
OUTPUT_PATH="$(pwd)/test_data/output"

# Load current configs
source ../../00.config.sh

set -x

case $1 in
  apikey)
    echo "Testing with API KEY..."
    source ../../test-authn-apikey/user.conf
    
    docker run -it --rm \
      -e AUTH_METHOD=apikey \
      -e CONJUR_APPLIANCE_URL="https://conjur.$POC_DOMAIN:$POC_CONJUR_HTTPS_PORT" \
      --add-host="conjur.$POC_DOMAIN:$CONJUR_IP" \
      -e CONJUR_ACCOUNT="$POC_CONJUR_ACCOUNT" \
      -e CONJUR_USER="$USER" \
      -e CONJUR_API_KEY="$KEY" \
      -e VARIABLE_PATH="test/host1/pass" \
      -v "$PUBLIC_KEY_PATH":/app/public_key.pem \
      -v "$OUTPUT_PATH":/app/output \
      $IMAGE_NAME
    ;;

  jwt)
    echo "Testing with JWT..."
    source ../../test-authn-jwt/00.config.sh
    JWT_PATH="../../test-authn-jwt/data/jwt"
    
    docker run -it --rm \
      -e AUTH_METHOD=jwt \
      -e CONJUR_APPLIANCE_URL="https://conjur.$POC_DOMAIN:$POC_CONJUR_HTTPS_PORT" \
      --add-host="conjur.$POC_DOMAIN:$CONJUR_IP" \
      -e CONJUR_ACCOUNT="$POC_CONJUR_ACCOUNT" \
      -e JWT_SERVICE_ID="$JWT_SERVICE_ID" \
      -e JWT_HOST_ID="$JWT_HOST_ID" \
      -e VARIABLE_PATH="test/host1/pass" \
      -v "$JWT_PATH":/app/jwt_token \
      -v "$PUBLIC_KEY_PATH":/app/public_key.pem \
      -v "$OUTPUT_PATH":/app/output \
      $IMAGE_NAME
    ;;

  *)
    echo "Usage: $0 {apikey|jwt}"
    exit 1
    ;;
esac

set +x