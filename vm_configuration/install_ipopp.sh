#!/bin/bash

# =============================
# IPOPP Install
# =============================

#   Set some environment variables
	export SOURCE_DIR=/datadrive
	export INSTALL_DIR=/datadrive/IPOPP
#	export IPOPP_TAR_GZ_FILENAME='DRL-IPOPP_4.1.tar.gz'
#	export PATCH_FILE_NAME='DRL-IPOPP_4.1_PATCH_1.tar.gz'

    cd $SOURCE_DIR
    tar -C $SOURCE_DIR -xzf DRL-IPOPP_4.1.tar.gz
    chmod -R 755 IPOPP
	sudo chown -R adminuser $SOURCE_DIR
	sudo chgrp -R adminuser $SOURCE_DIR
	$INSTALL_DIR/install_ipopp.sh -installdir $INSTALL_DIR/drl -datadir $INSTALL_DIR/data  -ingestdir $INSTALL_DIR/data/ingest

# 	Add SQL Path for Patch Installation DB Check
    export PATH=$PATH:$INSTALL_DIR/drl/standalone/mariadb-10.1.8-linux-x86_64/bin:$INSTALL_DIRc/drl/standalone/jdk1.8.0_45/bin

# 	Install IPOPP Patch #1
	cp $SOURCE_DIR/DRL-IPOPP_4.1_PATCH_1.tar.gz $INSTALL_DIR/drl
    $INSTALL_DIR/drl/tools/install_patch.sh DRL-IPOPP_4.1_PATCH_1.tar.gz

# 	Install IPOPP Patch #2
	cp $SOURCE_DIR/DRL-IPOPP_4.1_PATCH_2.tar.gz $INSTALL_DIR/drl
	$INSTALL_DIR/drl/tools/install_patch.sh DRL-IPOPP_4.1_PATCH_2.tar.gz

# 	Start Services
	$INSTALL_DIR/drl/tools/services.sh start

# 	Create .netrc file for MODIS Sensor geolocation module requires access to additional ephemeris and attitude ancillary files during processing. These files will be automatically retrieved using EarthData portal login credentials.
	cp $INSTALL_DIR/drl/SPA/modisl1db/algorithm/DRLshellscripts/sample.netrc $HOME/.netrc
# 	Next edit the $HOME/.netrc file to replace “yourlogin” and “yourpassword” with your EarthData portal credentials.

# 	Update .bashrc with LD_LIBRARY_PATH for RDP
	echo export LD_LIBRARY_PATH=/datadrive/IPOPP/drl/standalone/lib >> .bashrc

#	Install python request package
	python3 -m pip install requests

# 	Move aqua_datachecker.py to /nfsdata
	sudo mv /var/lib/waagent/custom_data/downloads/0/aqua_datachecker.py /nfsdata
	sudo chmod 777 /nfsdata/aqua_datachecker.py 

	#	Edit crontab to mount blobfuse on reboot
	crontab -l | { cat; echo "@reboot yum upgrade -y"; } | crontab -
	crontab -l | { cat; echo "@reboot blobfuse2 mount all /bf2all --config-file=/opt/blob-fuse/config.yaml"; } | crontab -
	crontab -l -u adminuser| { cat; echo "@reboot "/datadrive/IPOPP/drl/tools/services.sh start""; } | crontab -u adminuser -

# 	Verify
	$INSTALL_DIR/drl/tools/services.sh status > status.log
	$INSTALL_DIR/drl/tools/spa_services.sh status >> status.log	