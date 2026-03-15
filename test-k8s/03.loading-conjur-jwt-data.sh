#/bin/sh

K8SINF_FILE="k8s.info"
if [[ -f "$K8SINF_FILE" ]]; then
    echo "$K8SINF_FILE found."
else
    echo "Please generate k8s.jwks by running 02.get-k8s-publickey.sh script before running this script"
    exit
fi

source $K8SINF_FILE

set -x

conjur variable set -i conjur/authn-jwt/k8s/public-keys -v "{\"type\":\"jwks\", \"value\":$PUBLIC_KEYS}"
conjur variable set -i conjur/authn-jwt/k8s/issuer -v $ISSUER
conjur variable set -i conjur/authn-jwt/k8s/token-app-property -v sub
conjur variable set -i conjur/authn-jwt/k8s/identity-path -v jwt-apps/k8s
conjur variable set -i conjur/authn-jwt/k8s/audience -v cybrdemo

set +x
