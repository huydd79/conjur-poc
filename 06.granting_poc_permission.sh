#!/bin/bash

source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi


#Finding "DEMO:group:poc/sync1/conjur/delegation/consumers" to see if vault data has been sync and add to policy
data=$(conjur list | grep "delegation/consumers")

if [[ $? -eq 0 ]]; then
    echo -n "" > ./policies/poc-permission.yaml
    for d in $data; do
	group=`echo $d | sed 's/.*group:\(.*\)",/\1/g'`
	echo "Vault synchronizer's group found: $group. Adding member for POC ... "
	cat <<EOF >> ./policies/poc-permission.yaml
- !grant
  role: !group $group
  member:
    - !group test/test_users
    - !layer test/test_hosts
EOF
    done
    conjur policy load -f ./policies/poc-permission.yaml -b root
    [[ $? -eq 0 ]] && echo "Done"  || echo "ERROR!!!"
else
    echo "Vault data is not found. Please configure Vault Synchronizer to continue..."
fi

