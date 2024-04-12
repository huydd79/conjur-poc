# Conjur POC Quick start
This repo contains scripts for quick implementation and testing of CyberArk Conjur Enterprise for POC or self-learning environment build up.

Any comments, feel free to contact huy.do@cyberark.com

## Prerequisites
These scripts have been built and tested on Ubuntu version 20.4 LTS. Conjur appliance are installed on docker environment. Some tools that requires for running scripts as below:
- docker
- openssl
- jq
- python3
  
## Usage 
- Create /opt/upload folder and copy conjur appliance image, conjur cli package to this folder. Contact your CyberArk's representative for those files and package.
- Edit 00.config.sh to put in your environment setup detail. Remember to change default password which is ``ChangMe123!`` in this config file. Set READY=true when done.
- Run 00.installing_docker.sh to check and install docker environment
- Run scripts no 01-03 for conjur leader implementation. After script 03, check connection to conjur leader using curl -sk https://conjur-host:443/info
- Run script 04 for installing and setting up conjur CLI environment and login as admin user for further configuration
- Run script 05 to add demo data to conjur. Demo data will have sample test user, host, group, layer and several secrets for testing purpose
- Script 06 will require Conjur Vault Synchronizer setup completely before running. This script will asign permission for test user so that it can access to secrets those are synced from Vautl

## Authentication sample for application
There are two simple test cases of application authentication when sending request to conjur and retrieving secret value. 

### test-authn-apikey
This folder contain scripts to simulate an application request using API. The request is done by using curl and using simple authentication with username and api key. For running test case, you need to run sript 01 to create user.conf file with authentcation data. 
After that, script 02 will do the authentication testing and retrieving secret content.

### test-authn-jwt
This folder contain scripts to simulate an application request using JWT authentiation. You will need to use jwtgen tool to generate jwt token and configure conjur to accept authn-jwt authenticator and also trust the jwt issuer. Detail of jwtgen can be seen at https://github.com/huydd79/jwtgen
After done script 01 and 02 for generating jwt and configuring conjur, you can run sript 03 to simulate the application sending request to conjur using rest api

### test-authn-restriction
This folder contains script to test the configuration of IP restriction for user/host when doing authentication. Run sript 01 to generate configuration file for authentication purpose. Script 02 will add current conjur IP to the restriction list for testhost01 so that only request sending from conjur server is accepted for authentication. Run script 03 will show the authentication successfully but if you copy same curl command and run on other machine, the result will be empty. And in the sametime conjur's log will show the error: ```CONJ00048I Authentication Error: #<Errors::Authentication::InvalidOrigin: CONJ00003E User is not authorized to login from the current origin>```

## Hope this help you to quickly build up your conjur environment for testing and poc/demo purpose
