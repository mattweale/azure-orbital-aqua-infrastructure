#!/bin/bash

#	=============================
#	RT-STPS Install
#	=============================

	echo "Now on the RT-STPS Install"
	echo "First let's install azcopy"
	
#   	Install az copy
	cd ~
	curl "https://azcopyvnext.azureedge.net/release20221005/azcopy_linux_amd64_10.16.1.tar.gz" > azcopy_linux_amd64_10.16.1.tar.gz
	tar -xvf azcopy_linux_amd64_10.16.1.tar.gz
	cp ./azcopy_linux_amd64_*/azcopy /usr/bin/

#	Apply Udates
	echo "Now let's upgrade packages"
	yum upgrade -y 

# 	Install XRDP Server
	echo "Now let's install XRDP"
	yum install -y epel-release
	yum groupinstall -y "Server with GUI"
	yum groupinstall -y "Gnome Desktop"
	yum install -y tigervnc-server xrdp	
	systemctl enable xrdp.service
	systemctl start xrdp.service
	systemctl set-default graphical.target

#   	Download RT_STPS Software and Test Data
	echo "Now let's download RT-STPS v7.0 and  some test data"
	export CONTAINER="https://${AQUA_TOOLS_SA}.blob.core.windows.net/rt-stps/"
	export SOURCE_DIR=/datadrive
	export RTSTPS_DIR=/datadrive/rt-stps/

	azcopy login --identity
	
	azcopy cp "${CONTAINER}RT-STPS_7.0.tar.gz" "$SOURCE_DIR"
	azcopy cp "${CONTAINER}RT-STPS_7.0_testdata.tar.gz" "$SOURCE_DIR"
	azcopy cp "${CONTAINER}test2.bin" "$SOURCE_DIR"

# 	Install RT-STPS
	echo "Now let's install RT-STPS v7.0"
	cd $SOURCE_DIR
	tar -xzvf RT-STPS_7.0.tar.gz
	cd rt-stps
	./install.sh

# 	Update leapsec file
	cd /datadrive/rt-stps
	./bin/internal/update_leapsec.sh
	
#	Install Python3 and Bitstring Package for AQUA ASM Validation Script
	echo "Now let's install Python3"
	yum install python3 -y
	yum install python3-bitstring -y

#	Move AQUA ASM Validation Script to /datadrive/data
	Move aqua_datachecker.py to /nfsdata
	mv /var/lib/waagent/custom_data/downloads/0/aqua_datachecker.py /datadrive/data
	chmod 777 /datadrive/data/aqua_datachecker.py 
	
#	Edit crontab to mount blobfuse and start RT-STPS Server on reboot
	crontab -l | { cat; echo "@reboot yum upgrade -y"; } | crontab -
	crontab -l | { cat; echo "@reboot blobfuse2 mount all /bf2all --config-file=/opt/blob-fuse/config.yaml"; } | crontab -
	crontab -l -u adminuser| { cat; echo "@reboot /datadrive/IPOPP/drl/tools/services.sh start"; } | crontab -u adminuser -

# 	Echo how to start RT-STPS, Viewer and Sender
	echo 'Start RT-STPS Server with: ./rt-stps/jsw/bin/rt-stps-server.sh start'
	cd /datadrive
	./rt-stps/jsw/bin/rt-stps-server.sh start
	echo 'Start Viewer with: /datadrive/rt-stps/bin/viewer.sh &'
	echo 'Start Sender with: /datadrive//rt-stps/bin/sender.sh &'