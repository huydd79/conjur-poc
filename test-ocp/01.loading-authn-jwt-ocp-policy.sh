#!/bin/bash

set +x
conjur -d policy load -b root -f authn-jwt-ocp.yaml
set -x