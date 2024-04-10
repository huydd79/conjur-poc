#!/bin/bash

#Change your configuration and set READY=true when done
READY=true

#IP addresses of conjur and crc VM
CONJUR_IP=192.168.13.58
POC_IP=$CONJUR_IP
POC_DOMAIN=home.huydo.net
POC_CONJUR_ADMIN_PW=ChangeMe123!
POC_CONJUR_ACCOUNT=DEMO
POC_CONJUR_HTTPS_PORT=8443
#Path to folder with all docker images
UPLOAD_DIR=/opt/upload
conjur_appliance_file=conjur-appliance-Rls-v13.2.0.tar.gz
conjur_version=13.2.2
#Conjur container name
node_name=conjur
