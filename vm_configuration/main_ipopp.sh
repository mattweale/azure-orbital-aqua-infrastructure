#!/bin/bash

sudo ./mount_data_drive.sh
sudo ./mount_container.sh
sudo -E bash -c ./prereqs_ipopp.sh
su -c "/datadrive/install_ipopp.sh" -s /bin/bash adminuser
