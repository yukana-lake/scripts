#!/bin/bash

# Allow mounting of the first partition contained in a file secured by LUKS.
# 2019.10.16

# Import variables
source _vars.sh

# Get name of the loop device mapper (can be loop0, loop1, etc... if kpartx is already being used)
LOOP_DEVICE=$(sudo kpartx -a $PATH_FILE -p $DEVICE_NAME_DELIMITER -l | cut -d":" -f 1)

# Create device map of image file
sudo kpartx -a $PATH_FILE -p $DEVICE_NAME_DELIMITER

# Open crypted file
sudo cryptsetup open "/dev/mapper/"$LOOP_DEVICE $CRYPT_DEVICE_NAME

# Mount ext4 partition
sudo mount -t ext4 "/dev/mapper/$CRYPT_DEVICE_NAME" $MOUNTING_POINT

