#!/bin/sh

add () {
  # run add in a subshell so we can exit on failure.
  (
  echo Attmpting to mount $1 at path $2 if exists
  set -e
  test -z "$(blkid $1)"
  mkfs -t ext4 -L $3 $1
  mkdir -p $2
  mount $1 $2
  cat << EOF >> /etc/dremio/dremio.conf
services.executor.cache.path.fs += "${2}/cache/"
paths.spilling += "${2}/spilling"
services.executor.cache.pctquota.fs += "95"
EOF
  mkdir -p $2/cache/fs/ $2/cache/db/cm
  chown -R dremio:dremio $2
  )
}


# Optionally set up additional cache paths
add /dev/nvme1n1 /mnt/c1 c1 && ln -s /mnt/c1 /var/lib/dremio/data 
add /dev/nvme2n1 /mnt/c2 c2
add /dev/nvme3n1 /mnt/c3 c3
add /dev/nmve4n1 /mnt/c4 c4
