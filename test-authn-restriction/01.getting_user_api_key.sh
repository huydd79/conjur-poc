#!/bin/bash

echo -n "Updating host.conf file ... "
key=$(conjur host rotate-api-key -i "test/testhost01")
if [[ $? -eq 0 ]]; then
    echo "done"
    echo HOST="host%2Ftest%2Ftesthost01" > host.conf
    echo KEY="$key" >> host.conf
else
    echo "FAILED!!!"
fi