#/bin/sh


set -x
PUBLIC_KEYS="$(kubectl get --raw $(kubectl get --raw /.well-known/openid-configuration | jq -r '.jwks_uri'))"

if [[ -z $PUBLIC_KEYS ]]; then
    echo "Your environment does not have kubectl. Get the public keys manually by running this script at k8s management console and copy k8s.jwks into this folder to continue..."
    exit
fi
ISSUER="$(kubectl get --raw /.well-known/openid-configuration | jq -r '.issuer')"


echo "PUBLIC_KEYS='$PUBLIC_KEYS'" > k8s.info
echo "ISSUER='$ISSUER'" >> k8s.info

set +x
