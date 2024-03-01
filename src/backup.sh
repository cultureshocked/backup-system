#!/bin/bash

# Check if hot-media is connected to the computer
CONNECTED_STATUS=$(lsblk -o serial | awk '/60A44C413985F2A1997501D9/ {print $NF}')
echo $CONNECTED_STATUS

if [[ -z $CONNECTED_STATUS ]]; then
  echo "ERR: Hot-Media not connected to device."

  #Ideally restart the job in 15min with some sort of sleep, but skip for now
  exit
fi

TIMESTAMP=$(date +%s) # generate unix timestamp
BACKUP_NAME="$TIMESTAMP"-backup
BACKUP_DIR=/tmp/$BACKUP_NAME
BACKUP_FILENAME="$BACKUP_NAME".7z

MOUNT_POINT=$(lsblk -o name,serial,mountpoint | awk "/$CONNECTED_STATUS/ {print \$NF}")
DEVICE_NAME=/dev/$(lsblk -o name,serial | awk "/$CONNECTED_STATUS/ {print \$1}")

if [[ $MOUNT_POINT == $CONNECTED_STATUS ]]; then
  MOUNT_POINT=/mnt/backup
  # DEVICE_NAME=/dev/$(lsblk -o name,serial | awk "/$CONNECTED_STATUS/ {print \$1}")
  # echo $DEVICE_NAME
  sudo mount --mkdir $DEVICE_NAME $MOUNT_POINT
fi

BACKUP_TARGET="$MOUNT_POINT"/backup-daily

DIRECTORIES=( )
readarray -t DIRECTORIES < ./directories_to_backup.txt

# prepare temp directory for aggregating all files to backup
mkdir $BACKUP_DIR

for i in ${DIRECTORIES[@]}
do
  echo "Copying $i to $BACKUP_DIR ..."
  cp -r $i $BACKUP_DIR

done

echo $(ls -la $BACKUP_DIR)

7z a -mx9 -mmt4 "/tmp/$BACKUP_FILENAME" "$BACKUP_DIR"

#DEBUG
echo "BACKUP_NAME = $BACKUP_NAME"
echo "BACKUP_DIR = $BACKUP_DIR"
echo "BACKUP_FILENAME = $BACKUP_FILENAME"
echo "BACKUP_TARGET = $BACKUP_TARGET"
echo "MOUNT_POINT = $MOUNT_POINT"
#END DEBUG

rm -rf $BACKUP_DIR

sudo umount $DEVICE_NAME 
