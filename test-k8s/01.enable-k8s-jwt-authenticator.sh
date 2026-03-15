#/bin/sh
node_name=conjur

set -x
conjur -d policy load -f authn-jwt-k8s.yaml -b root

docker exec -it $node_name sh -c 'grep -q "authn,authn-jwt/k8s" /opt/conjur/etc/conjur.conf || echo "CONJUR_AUTHENTICATORS=\"authn,authn-jwt/k8s\"\n">>/opt/conjur/etc/conjur.conf'
docker exec $node_name sv restart conjur
set +x
