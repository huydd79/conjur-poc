#!/bin/bash

set +x

docker exec conjur bash -c "openssl rand -out /opt/conjur/backup/key -base64 64; evoke backup"

set -x