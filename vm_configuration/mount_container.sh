#!/bin/bash

#	=============================
#	NFS Mount Container
#	=============================
    echo "Mounting the Aqua Container: ${AQUA_NFS_SHARE} to /nfsdata"
   
#	Check Linux Distro for nfs utils install
    source /etc/os-release
    if [ "$NAME" = "CentOS Linux" ]; then
	    echo "Found RHEL Distro installing using yum"
        sudo yum install nfs-utils -y
    elif [ "$NAME" = "Ubuntu" ]; then
	    echo "echo Found Ubuntu Distro installing using apt"
        sudo apt install nfs-common -y
    else
        echo "What OS are you running!?"
    fi

#   Check VM Role to Mount right Container

    sudo mkdir -p /nfsdata

    if [ "$HOSTNAME" = "vm-orbital-data-collection" ]; then
	    echo "Found Data Collection VM mounting /${AQUA_NFS_SHARE}/raw-data"
        sudo mount -o sec=sys,vers=3,nolock,proto=tcp ${AQUA_NFS_SHARE}.blob.core.windows.net:/${AQUA_NFS_SHARE}/shared  /nfsdata
    elif [ "$HOSTNAME" = "vm-orbital-rtstps" ]; then
	    echo "Found RT-STPS VM mounting /${AQUA_NFS_SHARE}/rt-stps"
        sudo mount -o sec=sys,vers=3,nolock,proto=tcp ${AQUA_NFS_SHARE}.blob.core.windows.net:/${AQUA_NFS_SHARE}/shared  /nfsdata
    elif [ "$HOSTNAME" = "vm-orbital-ipopp" ]; then
	    echo "Found IPOPP VM mounting /${AQUA_NFS_SHARE}/ipopp"
        sudo mount -o sec=sys,vers=3,nolock,proto=tcp ${AQUA_NFS_SHARE}.blob.core.windows.net:/${AQUA_NFS_SHARE}/shared  /nfsdata
        cd /nfsd
    else
        echo "What VM is this!?"
    fi

sudo chmod -R 777 /nfsdata

    #    [ "$NAME" = "Ubuntu" ]; echo $?
    #    [ "$NAME" = "CentOS Linux" ]; echo $?