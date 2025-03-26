#!/bin/sh

openssl s_client -showcerts \
    -connect conjur.poc.local:443 < /dev/null 2> /dev/null \
    | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > certs/conjur.pem

podman exec -it -u root jenkins \
    bash -c 'keytool -import -alias conjur \
    -keystore /opt/java/openjdk/lib/security/cacerts -file /certs/client/conjur.pem'
#Note: default cacerts passwd is changeit

