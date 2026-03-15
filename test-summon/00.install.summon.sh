#!/bin/bash

source ../00.config.sh
if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
curl -sSL https://raw.githubusercontent.com/cyberark/summon/main/install.sh | bash
curl -sSL https://raw.githubusercontent.com/cyberark/summon-conjur/master/install.sh | bash
set +x
