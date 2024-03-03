#!/bin/bash

TIMESTAMP=$(date +%s)
BACKUP_NAME="$TIMESTAMP$BACKUP_SUFFIX"
BACKUP_FILE="$BACKUP_NAME".7z
BACKUP_DIR_FULLPATH="$BACKUP_TMP_ROOT$BACKUP_NAME"
BACKUP_FILE_FULLPATH="$BACKUP_TMP_ROOT$BACKUP_FILE"

MOUNT_POINT=$(lsblk -o name,serial,mountpoint | awk "/$CONNECTED_STATUS/ {print \$NF}")
DEVICE_NAME=$(lsblk -o name,serial,mountpoint | awk "/$CONNECTED_STATUS/ {print \$1}")
DEVICE_NAME=/dev/$DEVICE_NAME

# I would have liked to keep this script pure, but I may as well mount the device here anyway.
# The other option is to read this in the main script and assign it there.
if [[ $MOUNT_POINT == $CONNECTED_STATUS ]]; then
  MOUNT_POINT=$DEFAULT_MOUNT_POINT
  sudo mount --mkdir $DEVICE_NAME $MOUNT_POINT
fi

BACKUP_TARGET_DIR="$MOUNT_POINT$BACKUP_ROOT"
BACKUP_TARGET_FILE="$BACKUP_TARGET_DIR$BACKUP_FILE"

BACKUP_INTEGRITY_FILE="$BACKUP_TARGET_DIR$INTEGRITY_FILE"
