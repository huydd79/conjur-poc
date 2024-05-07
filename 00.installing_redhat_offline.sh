#!/bin/sh


set -x

cd ../pkgs
dnf install *.rpm

systemctl enable podman-restart.service
systemctl start podman-restart.service

set +x

