#/bin/bash -e

[ -z $DOWNLOAD_URL ] && DOWNLOAD_URL=http://download.dremio.com/community-server/dremio-community-LATEST.noarch.rpm
if [ ! -f /opt/dremio/bin/dremio ]; then
  command -v yum >/dev/null 2>&1 || { echo >&2 "This script works only on Centos or Red Hat. Aborting."; exit 1; }
  yum install -y java-1.8.0-openjdk-devel $DOWNLOAD_URL
fi

service=$1
if [ -z "$service" ]; then
   echo "Require the service to start - master, coordinator or executor"
   exit 1
fi
storage_account=$2
access_key=$3

if [ -n "$storage_account" -a -n "$access_key" ]; then
  use_azure_storage=1
fi

# In Azure, /dev/sdb is ephemeral storage mapped to /mnt/resource.
# Additional disks are mounted after that...
DISK_NAME=/dev/sdc
DISK_PART=${DISK_NAME}1
DREMIO_HOME=/opt/dremio
DREMIO_CONFIG_DIR=/etc/dremio
DREMIO_CONFIG_FILE=$DREMIO_CONFIG_DIR/dremio.conf
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
  if [ -n '$use_azure_storage' ]; then
    zookeeper=$4
  else
    zookeeper=$2
  fi
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
    sudo -u dremio /opt/dremio/bin/dremio-admin upgrade
  fi
}

function setup_master {
  if [ -n '$use_azure_storage' ]; then
    storage_create_action "dremiodata" filesystem && \
    storage_create_action "dremiodata/accelerator" directory && \
    storage_create_action "dremiodata/uploads" directory
  fi

  configure_dremio_dist
  sed -i "s/executor.enabled: true/executor.enabled: false/" $DREMIO_CONFIG_FILE
  upgrade_master
}

function setup_coordinator {
  yum install -y nc
  until nc -z $zookeeper 9047 > /dev/null; do echo waiting for dremio master; sleep 2; done;
  configure_dremio_dist
  sed -i "s/coordinator.master.enabled: true/coordinator.master.enabled: false/; \
          s/executor.enabled: true/executor.enabled: false/" \
          $DREMIO_CONFIG_FILE
  echo "zookeeper: \"$zookeeper:2181\"" >> $DREMIO_CONFIG_FILE
}

function setup_executor {
  configure_dremio_dist
  setup_spill
  sed -i "s/coordinator.master.enabled: true/coordinator.master.enabled: false/; \
          s/coordinator.enabled: true/coordinator.enabled: false/; \
          /local:/a \ \ spilling: [\"$SPILL_DIR/spill\"]" \
          $DREMIO_CONFIG_FILE
  echo "zookeeper: \"$zookeeper:2181\"" >> $DREMIO_CONFIG_FILE
}

function storage_create_action {
  resource=$1
  resource_type=$2
  blob_store_url="dfs.core.windows.net"
  authorization="SharedKey"
  request_method="PUT"
  request_date=$(TZ=GMT date "+%a, %d %h %Y %H:%M:%S %Z")
  storage_service_version="2018-11-09"
  # HTTP Request headers
  x_ms_date_h="x-ms-date:$request_date"
  x_ms_version_h="x-ms-version:$storage_service_version"
  content_length_h="Content-Length: 0"
  # Build the signature string
  canonicalized_headers="${x_ms_date_h}\n${x_ms_version_h}"
  canonicalized_resource="/${storage_account}/${resource}\nresource:${resource_type}"
  string_to_sign="${request_method}\n\n\n\n\n\n\n\n\n\n\n\n${canonicalized_headers}\n${canonicalized_resource}"
  # Decode the Base64 encoded access key, convert to Hex.
  decoded_hex_key="$(echo -n $access_key | base64 -d -w0 | xxd -p -c256)"
  # Create the HMAC signature for the Authorization header
  signature=$(printf "$string_to_sign" | openssl dgst -sha256 -mac HMAC -macopt "hexkey:$decoded_hex_key" -binary |  base64 -w0)
  authorization_header="Authorization: $authorization $storage_account:$signature"
  curl \
    -X $request_method \
    -H "$content_length_h" \
    -H "$x_ms_date_h" \
    -H "$x_ms_version_h" \
    -H "$authorization_header" \
    "https://${storage_account}.${blob_store_url}/${resource}?resource=${resource_type}"
  return $?
}

function write_coresite_xml {
cat > $DREMIO_CONFIG_DIR/core-site.xml <<EOF
<?xml version="1.0"?>
<configuration>
<property>
 <name>fs.dremioAzureStorage.impl</name>
 <description>FileSystem implementation. Must always be com.dremio.plugins.azure.AzureStorageFileSystem</description>
 <value>com.dremio.plugins.azure.AzureStorageFileSystem</value>
</property>
<property>
  <name>dremio.azure.account</name>
  <description>The name of the storage account.</description>
  <value>$storage_account</value>
</property>
<property>
  <name>dremio.azure.key</name>
  <description>The shared access key for the storage account.</description>
  <value>$access_key</value>
</property>
<property>
  <name>dremio.azure.mode</name>
  <description>The storage account type. Value: STORAGE_V2</description>
  <value>STORAGE_V2</value>
</property>
<property>
  <name>dremio.azure.secure</name>
  <description>Boolean option to enable SSL connections. Value: True/False</description>
  <value>True</value>
</property>
</configuration>
EOF
}

function update_dremio_config {
cat >> $DREMIO_CONFIG_FILE <<EOF

paths.accelerator: "dremioAzureStorage://:///dremiodata/accelerator"
paths.uploads: "dremioAzureStorage://:///dremiodata/uploads"
EOF
}

function configure_dremio_dist {
  if [ -n '$use_azure_storage' ]; then
    write_coresite_xml
    update_dremio_config
  fi
}

setup_$service
service dremio start
chkconfig dremio on
