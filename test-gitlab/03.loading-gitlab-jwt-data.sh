#!/bin/bash

set -x
conjur variable set -i conjur/authn-jwt/gitlab/jwks-uri -v https://gitlab.home.huydo.net/-/jwks/
conjur variable set -i conjur/authn-jwt/gitlab/token-app-property -v project_path
conjur variable set -i conjur/authn-jwt/gitlab/identity-path -v jwt-apps/gitlab
conjur variable set -i conjur/authn-jwt/gitlab/issuer -v https://gitlab.home.huydo.net


CA_CERT=$(cat gitlab-ca.crt)
conjur variable set -i conjur/authn-jwt/gitlab/ca-cert -v "$CA_CERT"
set +x
