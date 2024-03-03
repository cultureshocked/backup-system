#!/bin/bash

# Globals for you to define yourself
DEFAULT_MOUNT_POINT="/mnt/backup" # Default location to mount hot media (will mount with `--mkdir`)
BACKUP_ROOT="/backup-daily/"      # Root of where backups are stored on hot media 
BACKUP_SUFFIX="-backup"           # Backup files will be called [TIMESTAMP][SUFFIX]
BACKUP_TMP_ROOT="/tmp/"           # Where to aggregate all files to archive+backup
COMPRESSION_OPTIONS="-mx9 -mmt4"  # See `7z --help` for complete options. max compression + 4threads
INTEGRITY_FILE="integrity.txt"    # The filename of the hash store in the backup root folder

# Path to list of whitelisted directories to backup 
DIRECTORY_LIST="./directories_to_backup.txt"

# This is how the script determines which device is the hot media 
HOTMEDIA_SERIAL="60A44C413985F2A1997501D9"

# Check if hot-media is connected to the computer
# Status will be the serial number itself if connected, empty if not
CONNECTED_STATUS=$(lsblk -o serial | awk "/$HOTMEDIA_SERIAL/ {print \$NF}")
export CONNECTED_STATUS
export BACKUP_ROOT
export BACKUP_SUFFIX
export BACKUP_TMP_ROOT
export DEFAULT_MOUNT_POINT
export INTEGRITY_FILE

if [[ -z $CONNECTED_STATUS ]]; then
  echo "ERR: Hot-Media not connected to device."

  #Ideally restart the job in 15min with some sort of sleep, but skip for now
  exit
fi

source generate_paths.sh

DIRECTORIES=( )
readarray -t DIRECTORIES < ./directories_to_backup.txt

# prepare temp directory for aggregating all files to backup
mkdir $BACKUP_DIR_FULLPATH

for i in ${DIRECTORIES[@]}
do
  cp -r $i $BACKUP_DIR_FULLPATH
done

7z a $COMPRESSION_OPTIONS $BACKUP_FILE_FULLPATH $BACKUP_DIR
cp $BACKUP_FILE_FULLPATH $BACKUP_TARGET_FILE

rm -rf $BACKUP_DIR_FULLPATH

ARCHIVE_MD5="$(md5sum $BACKUP_FILE_FULLPATH | awk '{print $1}')"
ARCHIVE_SHA256="$(sha256sum $BACKUP_FILE_FULLPATH | awk '{print $1}')"
echo "$BACKUP_FILE $ARCHIVE_MD5 $ARCHIVE_SHA256" >> $BACKUP_INTEGRITY_FILE

rm $BACKUP_FILE_FULLPATH

sync
sudo umount $DEVICE_NAME 
