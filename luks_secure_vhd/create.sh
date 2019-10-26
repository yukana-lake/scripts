#!/bin/bash

# Create a virtual hard drive containing a single ext4 partition secured by LUKS (cryptsetup)
# 2019.10.16

# Variables used to run this script
# Size in Megabytes
while getopts s:p:m:d: option
do
	case "${option}"
	in
		s) SIZE=${OPTARG};; # Size in MBytes
                p) PATH_FILE=${OPTARG};; # Path to generated .img file
                m) MOUNTING_POINT=${OPTARG};; # Mounting point
                d) CRYPT_DEVICE_NAME=${OPTARG};; # Name of the crypted device
	esac
done

if [ -z "$SIZE" ] || [ -z "$PATH_FILE" ] || [ -z "$MOUNTING_POINT" ] || [ -z "$CRYPT_DEVICE_NAME" ]; 
then
	echo "Usage : ./create.sh -s {size of the VHD in Mbytes} -p {path to the generated VHD} -m {mounting point} -d {name of the crypted device}";
	exit
fi

sleep 60
# Path to generated .img file
chars="abcdefghijklmnopqrstuvwxyz"

# Variables used to generate the files to mount the crypted partition
DEVICE_NAME_DELIMITER=""

# Path to the folder where the generated scripts will be
FOLDER=$HOME"/scripts_"$CRYPT_DEVICE_NAME

# 1st step : generate file

sudo dd if=/dev/zero of=$PATH_FILE bs=1M count=$SIZE
# - Create GPT partition table and a single partition of the size of the disk
echo "g
n
1


w
"| sudo fdisk $PATH_FILE

# - Generate DEVICE_NAME_DELIMITER
for i in {1..4}; do
	DEVICE_NAME_DELIMITER="$DEVICE_NAME_DELIMITER""${chars:RANDOM%${#chars}:1}"
done

# - Get name of the loop device mapper (can be loop0, loop1, etc... if kpartx is already being used)
LOOP_DEVICE=$(sudo kpartx -a $PATH_FILE -p $DEVICE_NAME_DELIMITER -l | cut -d":" -f 1)
# - Create device map of image file
sudo kpartx -a $PATH_FILE -p $DEVICE_NAME_DELIMITER

# - Initialize the secured virtual disk (require user input)
sudo cryptsetup luksFormat "/dev/mapper/"$LOOP_DEVICE

# - Open secured device
sudo cryptsetup open "/dev/mapper/"$LOOP_DEVICE $CRYPT_DEVICE_NAME

# - Create ext4 partition on the secured device
sudo mkfs.ext4 "/dev/mapper/"$CRYPT_DEVICE_NAME

# - Mount the created partition
sudo mkdir -p $MOUNTING_POINT
sudo mount -t ext4 "/dev/mapper/"$CRYPT_DEVICE_NAME $MOUNTING_POINT

# 2nd step : generate the scripts to mount/unmount the volume easily
mkdir $FOLDER

# - Output variables into file and copy scripts
echo -e "PATH_FILE=$PATH_FILE \n MOUNTING_POINT=$MOUNTING_POINT \n DEVICE_NAME_DELIMITER=$DEVICE_NAME_DELIMITER \n CRYPT_DEVICE_NAME=$CRYPT_DEVICE_NAME" > "$FOLDER/_vars.sh"
cp "../luks/mount_secure.sh" "$FOLDER/"
cp "../luks/umount_secure.sh" "$FOLDER/"









