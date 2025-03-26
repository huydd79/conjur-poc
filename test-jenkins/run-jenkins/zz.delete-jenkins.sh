#!/bin/sh

podman stop jenkins
podman container rm $(podman ps -a | grep jenkins | awk '{print $1}')

rm -f /opt/jenkins/certs/*
rm -f /opt/jenkins/data/*
