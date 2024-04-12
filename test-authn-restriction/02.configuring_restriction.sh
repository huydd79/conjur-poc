#!/bin/bash

source ../00.config.sh
if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

echo -n "Adding ip restriction for host ... "
cat << EOF > host-update.yaml
- !host
  id: test/testhost01
  restricted_to: [$CONJUR_IP]
EOF

conjur policy update -f host-update.yaml -b root
