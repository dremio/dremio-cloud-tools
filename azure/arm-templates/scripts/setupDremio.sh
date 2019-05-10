#/bin/bash -e

[ -z $DOWNLOAD_URL ] && DOWNLOAD_URL=http://download.dremio.com/community-server/dremio-community-LATEST.noarch.rpm
if [ ! -f /opt/dremio/bin/dremio ]; then
  command -v yum >/dev/null 2>&1 || { echo >&2 "This script works only on Centos or Red Hat. Aborting."; exit 1; }
  yum install -y java-1.8.0-openjdk
  wget $DOWNLOAD_URL -O dremio-download.rpm
  yum -y localinstall dremio-download.rpm
fi

service=$1
if [ -z "$service" ]; then
   echo "Require the service to start - master, coordinator or executor"
   exit 1
fi

DISK_NAME=/dev/sdc
DISK_PART=${DISK_NAME}1
DREMIO_CONFIG_FILE=/etc/dremio/dremio.conf
DREMIO_DATA_DIR=/var/lib/dremio

function partition_disk {
  parted $DISK_NAME mklabel msdos
  parted -s $DISK_NAME mkpart primary ext4 0% 100%
  mkfs -t ext4 $DISK_PART
}

if [ "$service" == "master" ]; then
  lsblk -no FSTYPE $DISK_NAME | grep ext4 || partition_disk
  mount $DISK_PART $DREMIO_DATA_DIR
  chown dremio:dremio $DREMIO_DATA_DIR
  echo "$DISK_PART $DREMIO_DATA_DIR ext4 defaults 0 0" >> /etc/fstab
fi

if [ "$service" != "master" ]; then
  zookeeper=$2
  if [ -z "$zookeeper" ]; then
    echo "Non-master node requires zookeeper host"
    exit 2
  fi
fi

# Temp fix till resolved in base code
mkdir -p /opt/dremio/run
chown dremio:dremio /opt/dremio/run
sed -i "s/DREMIO_PID_DIR=*/#DREMIO_PID_DIR=/" /opt/dremio/conf/dremio-env

function setup_master {
#  sed -i "s/local: .*/local: /var/lib/dremio"
  sed -i "s/executor.enabled: true/executor.enabled: false/" $DREMIO_CONFIG_FILE
}

function setup_coordinator {
  yum install -y nc
  until nc -z $zookeeper 9047 > /dev/null; do echo waiting for dremio master; sleep 2; done;
  sed -i "s/coordinator.master.enabled: true/coordinator.master.enabled: false/; s/executor.enabled: true/executor.enabled: false/" $DREMIO_CONFIG_FILE
  echo "zookeeper: \"$zookeeper:2181\"" >> $DREMIO_CONFIG_FILE
}

function setup_executor {
  sed -i "s/coordinator.master.enabled: true/coordinator.master.enabled: false/; s/coordinator.enabled: true/coordinator.enabled: false/" $DREMIO_CONFIG_FILE
  echo "zookeeper: \"$zookeeper:2181\"" >> $DREMIO_CONFIG_FILE
}

setup_$service
service dremio start
chkconfig dremio on
