#!/bin/bash

set -x
conjur variable set -i conjur/authn-jwt/github/jwks-uri -v https://token.actions.githubusercontent.com/.well-known/jwks
#conjur variable set -i conjur/authn-jwt/github/token-app-property -v workflow
#This will use repository owner as hostid for authentication. Allow all workflow and repo to authenticate using same hostid
conjur variable set -i conjur/authn-jwt/github/token-app-property -v repository_owner
conjur variable set -i conjur/authn-jwt/github/identity-path -v jwt-apps/github
conjur variable set -i conjur/authn-jwt/github/issuer -v https://token.actions.githubusercontent.com
conjur variable set -i conjur/authn-jwt/github/enforced-claims -v "repository_owner_id"
set +x
