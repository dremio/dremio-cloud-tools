#!/bin/bash
set -x
#set -e
ls /tmp/uploads
sudo cp /tmp/uploads/cloud-init/* /etc/cloud/cloud.cfg.d/
sudo yum -y install \
  java-1.8.0-openjdk-devel \
  https://jenkins.drem.io/job/dremio-releases-release/1405/artifact/enterprise/distribution/server/target/rpm/dremio-enterprise/RPMS/noarch/dremio-enterprise-4.0.0-201909121834570395_c7a5071_1.noarch.rpm
sudo cp /opt/dremio/share/dremio/dremio.service /etc/systemd/system/dremio.service
sudo rm /etc/init.d/dremio
sudo systemctl daemon-reload
sudo cp /tmp/uploads/conf/* /etc/dremio/
sudo systemctl enable dremio
sudo rm -rf /tmp/uploads
