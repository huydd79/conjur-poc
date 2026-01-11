#!/bin/bash

#Change your configuration and set READY=true when done
READY=true

#Container env setting
SUDO=
CONTAINER_MGR=docker

#IP addresses of conjur and crc VM
CONJUR_IP=172.16.100.8
POC_IP=$CONJUR_IP
POC_DOMAIN=cybr.huydo.net
POC_CONJUR_ADMIN_PW=ChangeMe123!
POC_CONJUR_ACCOUNT=POC
POC_CONJUR_HTTPS_PORT=8443
#Path to folder with all docker images
UPLOAD_DIR=/opt/upload
conjur_appliance_file=conjur-appliance-Rls-v13.7.0.tar.gz
conjur_version=13.7.0
#Conjur container name
node_name=conjur
