#!/bin/bash

set +x
conjur -d policy load -b root -f authn-jwt-github.yaml
set -x