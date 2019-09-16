#!/bin/bash
BASE_URL="https://jenkins.drem.io/job/dremio-releases-release/lastSuccessfulBuild/artifact/enterprise/distribution/server/target/rpm/dremio-enterprise/RPMS/noarch/"
BUILD_ID=$(curl $BASE_URL | grep -o -m 1 '<a href=\"dremio-enterprise[^\">]*' | head -1 | sed -n -e 's/^.*"//p')
ARTIFACT_URL=$BASE_URL$BUILD_ID
set -x
#set -e
ls /tmp/uploads
sudo cp /tmp/uploads/cloud-init/* /etc/cloud/cloud.cfg.d/
sudo yum -y install \
  java-1.8.0-openjdk-devel \
  $ARTIFACT_URL
sudo cp /opt/dremio/share/dremio/dremio.service /etc/systemd/system/dremio.service
sudo rm /etc/init.d/dremio
sudo cp /tmp/uploads/conf/* /etc/dremio/
sudo rm -rf /tmp/uploads
sudo systemctl enable dremio
