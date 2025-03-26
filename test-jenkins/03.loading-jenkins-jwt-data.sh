#!/bin/bash

set -x
conjur variable set -i conjur/authn-jwt/jenkins/jwks-uri -v http://10.0.0.2:8080/jwtauth/conjur-jwk-set
conjur variable set -i conjur/authn-jwt/jenkins/token-app-property -v jenkins_full_name
conjur variable set -i conjur/authn-jwt/jenkins/identity-path -v jwt-apps/jenkins
conjur variable set -i conjur/authn-jwt/jenkins/issuer -v http://jenkins.poc.local:8080

set +x
