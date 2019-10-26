#!/bin/bash

# Allow unmounting of the first partition contained in a file secured by LUKS.
# 2019.10.16

# Import variables
source _vars.sh

# Unmount the secured partition
sudo umount $MOUNTING_POINT

# Close the secured file
sudo cryptsetup close $CRYPT_DEVICE_NAME

# Delete mapping of partition table
sudo kpartx -d $PATH_FILE
