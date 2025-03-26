#!/bin/sh

podman stop jenkins
podman container rm $(podman ps -a | grep jenkins | awk '{print $1}')

podman run \
    --name jenkins \
    --detach --restart=always\
    -p "8080:8080" \
    -v /opt/jenkins/data:/var/jenkins_home \
    -v /opt/jenkins/certs:/certs/client \
    --privileged \
    --env DOCKER_TLS_CERTDIR=/certs \
    --env JENKINS_UC_DOWNLOAD="http://mirrors.jenkins-ci.org" \
    jenkins/jenkins
