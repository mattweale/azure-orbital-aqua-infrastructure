#!/bin/bash

./mount_data_drive.sh
./mount_container.sh
sudo -E bash -c ./install_rtstps.sh
