#!/bin/bash

#	=====================================================================
#	Mount data disk - Might need to change sdc to sdb depending on Region
#	=====================================================================

echo "Mounting the data disk to /datadrive"
#lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | grep -i "sd"
parted /dev/sdc --script mklabel gpt mkpart xfspart xfs 0% 100%  # making partions, do not run on re-attaching an existing drive
mkfs.xfs /dev/sdc1
partprobe /dev/sdc1 
mkdir /datadrive # end making partions
mount /dev/sdc1 /datadrive #not permanent use fstab
sudo yum -y install util-linux
fstrim /datadrive
chown -R adminuser /datadrive
chgrp -R adminuser /datadrive

# Persist /datadrive
DATADRIVE_UUID=$(ls -l /dev/disk/by-uuid | grep sdc | grep -Po "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")
UUID_TXT="UUID=${DATADRIVE_UUID} /datadrive xfs defaults 0 0"
echo $UUID_TXT >> /etc/fstab