#!/bin/bash

source ./ocp.conf
set -x
PUBLIC_KEYS=$(echo $PUBLIC_KEYS | base64 -d)

conjur variable set -i conjur/authn-jwt/ocp/public-keys -v "{\"type\":\"jwks\", \"value\":$PUBLIC_KEYS}"
conjur variable set -i conjur/authn-jwt/ocp/issuer -v $ISSUER
conjur variable set -i conjur/authn-jwt/ocp/token-app-property -v sub
conjur variable set -i conjur/authn-jwt/ocp/identity-path -v jwt-apps/ocp
conjur variable set -i conjur/authn-jwt/ocp/audience -v cybrdemo

set +x
