#!/bin/bash

set -x
conjur policy update -f delete.yaml -b root
set +x
