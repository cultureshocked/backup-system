TIMESTAMP=$(date +%s)
BACKUP_NAME="$TIMESTAMP-backup"
BACKUP_FILE="$BACKUP_NAME".7z
BACKUP_DIR_FULLPATH="/tmp/$BACKUP_NAME"
BACKUP_FILE_FULLPATH="/tmp/$BACKUP_FILENAME"

MOUNT_POINT=$(lsblk -o name,serial,mountpoint | awk "/$CONNECTED_STATUS/ {print \$NF}")
DEVICE_NAME=$(lsblk -o name,serial,mountpoint | awk "/$CONNECTED_STATUS/ {print \$1}")

# I would have liked to keep this script pure, but I may as well mount the device here anyway.
# The other option is to read this in the main script and assign it there.
if [[ $MOUNT_POINT == $CONNECTED_STATUS ]]; then
  MOUNT_POINT=/mnt/backup
  sudo mount --mkdir $DEVICE_NAME $MOUNT_POINT
fi

BACKUP_TARGET_DIR="$MOUNT_POINT"/backup-daily/
BACKUP_TARGET_FILE="$BACKUP_TARGET_DIR$BACKUP_FILENAME"

