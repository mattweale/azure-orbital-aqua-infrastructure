#!/bin/bash

#	=============================
#	Mount Data Disk
#	=============================

echo "Mounting the Data Disk to /datadrive"
lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | grep -i "sd"
sudo parted /dev/sdc --script mklabel gpt mkpart xfspart xfs 0% 100%  # making partions, do not run on re-attaching an existing drive
sudo mkfs.xfs /dev/sdc1
sudo partprobe /dev/sdc1 
sudo mkdir /datadrive # end making partions
sudo mount /dev/sdc1 /datadrive #not permanent use fstab
sudo yum -y install util-linux
sudo fstrim /datadrive
sudo chown -R adminuser /datadrive
sudo chgrp -R adminuser /datadrive
