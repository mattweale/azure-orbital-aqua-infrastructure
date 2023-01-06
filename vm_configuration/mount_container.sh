#!/bin/bash

#	==============================
#	NFS Mount Container to /shared
#	==============================
    echo "Mounting the Aqua Container: ${AQUA_NFS_SHARE} to /nfsdata"
   
#	Check Linux Distro for nfs utils install
    source /etc/os-release
    if [ "$NAME" = "CentOS Linux" ]; then
	    echo "Found RHEL Distro installing using yum"
        yum install nfs-utils -y
    elif [ "$NAME" = "Ubuntu" ]; then
	    echo "echo Found Ubuntu Distro installing using apt"
        apt install nfs-common -y
    else
        echo "What OS are you running!?"
    fi

#   Check VM Role to Mount right Container

    sudo mkdir -p /nfsdata

    if [ "$HOSTNAME" = "vm-orbital-data-collection" ]; then
	    echo "Found Data Collection VM mounting /${AQUA_NFS_SHARE}/raw-data"
        mount -o sec=sys,vers=3,nolock,proto=tcp ${AQUA_NFS_SHARE}.blob.core.windows.net:/${AQUA_NFS_SHARE}/shared  /nfsdata
    elif [ "$HOSTNAME" = "vm-orbital-rtstps" ]; then
	    echo "Found RT-STPS VM mounting /${AQUA_NFS_SHARE}/rt-stps"
        mount -o sec=sys,vers=3,nolock,proto=tcp ${AQUA_NFS_SHARE}.blob.core.windows.net:/${AQUA_NFS_SHARE}/shared  /nfsdata
    elif [ "$HOSTNAME" = "vm-orbital-ipopp" ]; then
	    echo "Found IPOPP VM mounting /${AQUA_NFS_SHARE}/ipopp"
        mount -o sec=sys,vers=3,nolock,proto=tcp ${AQUA_NFS_SHARE}.blob.core.windows.net:/${AQUA_NFS_SHARE}/shared  /nfsdata
    else
        echo "What VM is this!?"
    fi

sudo chmod -R 777 /nfsdata

echo ${AQUA_NFS_SHARE}.blob.core.windows.net:/${AQUA_NFS_SHARE}/shared  /nfsdata    nfs defaults,sec=sys,vers=3,nolock,proto=tcp,nofail    0 0 >> /etc/fstab 

#   Install blobfuse2
wget https://github.com/Azure/azure-storage-fuse/releases/download/blobfuse2-2.0.1/blobfuse2-2.0.1-CentOS-7.0-x86-64.rpm
yum install libfuse3-dev fuse3 -y
rpm -i blobfuse2-2.0.1-CentOS-7.0-x86-64.rpm

#   Create blobfuse mount points, tempcache and config file
mkdir -p /bf2all
mkdir /opt/blob-fuse
mkdir /opt/blob-fuse/tempcache
chmod -R 777 /opt/blob-fuse
mkdir -p /bf2all/raw-contact-data
mkdir -p /bf2all/shared
chmod -R 777 /bf2all/raw-contact-data
chmod -R 777 /bf2all/shared

cat <<EOT  >  /opt/blob-fuse/config.yaml
allow-other: true

logging:
  type: syslog
  level: log_debug

components:
  - libfuse
  - file_cache
  - attr_cache
  - azstorage

libfuse:
  attribute-expiration-sec: 120
  entry-expiration-sec: 120
  negative-entry-expiration-sec: 240

file_cache:
  path: /opt/blob-fuse/tempcache
  timeout-sec: 120
  max-size-mb: 4096
  cleanup-on-start: true
  allow-non-empty-temp: true

attr_cache:
  timeout-sec: 7200

azstorage:
  type: block
  account-name: ${T2B_SA_NAME}
  container: raw-contact-data
  container: shared
  endpoint: https://${T2B_SA_NAME}.blob.core.windows.net
  mode: msi
  appid: ${AQUA_MI_ID}

health_monitor:
  enable-monitoring: true
  stats-poll-interval-sec: 10
  process-monitor-interval-sec: 30
  output-path: outputReportsPath
  monitor-disable-list:
    - file_cache_monitor
    - memory_profileraw
EOT

blobfuse2 mount all /bf2all --config-file=/opt/blob-fuse/config.yaml --allow-other

