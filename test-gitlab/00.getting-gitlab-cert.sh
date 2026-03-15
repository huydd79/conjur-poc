#!/bin/bash

set +x
openssl s_client -showcerts \
    -connect  gitlab.com:443 </dev/null 2>/dev/null \
    | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > gitlab-ca.crt

#DDH: NEED to check the gitlab-ca.crt to make sure it contains full cert chain or at least the root CA cert
set -x