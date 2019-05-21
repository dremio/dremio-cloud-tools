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

# In Azure, /dev/sdb is ephemeral storage mapped to /mnt/resource.
# Additional disks are mounted after that...
DISK_NAME=/dev/sdc
DISK_PART=${DISK_NAME}1
DREMIO_CONFIG_FILE=/etc/dremio/dremio.conf
DREMIO_DATA_DIR=/var/lib/dremio
# Azure Linux VMs have ephemeral/temporary disk
# always mounted on /mnt/resource/dremio
SPILL_DIR=/mnt/resource/dremio

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
else
  zookeeper=$2
  if [ -z "$zookeeper" ]; then
    echo "Non-master node requires zookeeper host"
    exit 2
  fi
fi

function setup_spill {
  chmod +w /etc/sysconfig/dremio
  cat >> /etc/sysconfig/dremio <<EOF

#wait for /mnt/resource to be created
while [ \$(mount | grep /mnt/resource | wc -l) -lt 1 ];
do
    echo "Waiting five more seconds for /mnt/resource to be created by waagent..."
    sleep 5
done

# test if folder is missing. If so, create it, set SE context & ownership
if [ ! -d $SPILL_DIR ]; then
    mkdir -p $SPILL_DIR
    chown dremio:dremio $SPILL_DIR
    echo "$SPILL_DIR created."
else
    echo "$SPILL_DIR already exists."
fi
EOF
}

function upgrade_master {
  cd $DREMIO_DATA_DIR
  if [ -d db ]; then
    tar -zcvf dremio_db_$(date '+%Y-%m-%d_%H-%M').tar.gz db
    /opt/dremio/bin/dremio-admin upgrade
  fi
}

function setup_master {
  sed -i "s/executor.enabled: true/executor.enabled: false/" $DREMIO_CONFIG_FILE
  upgrade_master
}

function setup_coordinator {
  yum install -y nc
  until nc -z $zookeeper 9047 > /dev/null; do echo waiting for dremio master; sleep 2; done;
  sed -i "s/coordinator.master.enabled: true/coordinator.master.enabled: false/; \
          s/executor.enabled: true/executor.enabled: false/" \
          $DREMIO_CONFIG_FILE
  echo "zookeeper: \"$zookeeper:2181\"" >> $DREMIO_CONFIG_FILE
}

function setup_executor {
  setup_spill
  sed -i "s/coordinator.master.enabled: true/coordinator.master.enabled: false/; \
          s/coordinator.enabled: true/coordinator.enabled: false/; \
          /local:/a \ \ spilling: [\"$SPILL_DIR/spill\"]" \
          $DREMIO_CONFIG_FILE
  echo "zookeeper: \"$zookeeper:2181\"" >> $DREMIO_CONFIG_FILE
}

setup_$service
service dremio start
chkconfig dremio on
