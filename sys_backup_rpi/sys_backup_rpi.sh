#!/bin/bash

# Simple script to backup a Raspberry Pi system
# 2019.10.18

# Check if user is root
if [ "$EUID" -ne 0 ]; then 
	echo "Please run as root"
	exit
fi

# Set backup destination
BACKUP_DESTINATION="/mnt/disk1/backups/system/"

# Set file which contain exclusions
EXCLUSIONS="exclusions.txt"

# Set logs output
LOG_DIR=".logs/"
LOG_FILE=$LOG_DIR"backup-$(date +\%Y\_\%m\_\%d\_\%H-\%M-\%S).log"

# Check if directory exists, create if it doesnt't
if [ ! -d "$LOG_DIR" ]; then
	mkdir $LOG_DIR
fi

# Execute backup
rsync -ravzX  --delete --exclude-from $EXCLUSIONS / $BACKUP_DESTINATION --log-file=$LOG_FILE --progress

