#!/bin/bash

# File containing variables used in theses scripts
# 2019.10.16

# Path to the raw image of the disk
PATH_FILE="/srv/nfs/data.img"
# Path where the secured partition will be mounted to
MOUNTING_POINT="/srv/nfs/secure"
# This has to be unique = not used by another mapper by kpartx
DEVICE_NAME_DELIMITER="delm"
# Name used by cryptsetup to identify the device 
CRYPT_DEVICE_NAME="secure"
