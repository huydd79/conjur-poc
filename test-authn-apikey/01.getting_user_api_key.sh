#!/bin/bash

echo -n "Updating user.conf file ... "
key=$(conjur user rotate-api-key -i testuser01@test)
if [[ $? -eq 0 ]]; then
    echo "done"
    echo USER="testuser01@test" > user.conf
    echo KEY="$key" >> user.conf
else
    echo "FAILED!!!"
fi