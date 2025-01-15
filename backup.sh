#!/bin/bash

: '
DOC

This backup script creates and stores linux backups in /mnt/. Please ensure that the backups are stored on separate hardware or storage devices within a reasonable timespan. The corresponding logs are stored in /var/log/rsync.

For automatic backups, you can add a line to your crontab using `sudo crontab -e`. For example, to run this backup script at every system boot you could add:

@reboot /path/to/script /path/to/source_directory

The rsync options used in the script are:

    -a: Archive mode (preserves symbolic links, file permissions, user & group ownerships, and timestamps).
    -v: Verbose output.
    -b: Make backups of files that are overwritten or deleted.
    --backup-dir: Specifies the directory where backups of changed files will be stored, which is created with the current date.
    --delete: Deletes files from the destination that no longer exist in the source directory.

Please make sure to add execute permissions.

'

if [ $# -ne 1 ]
then
        echo "Usage: backup.sh <source_directory>"
        echo "Please try again."
        exit 1
fi

if ! command -v rsync > /dev/null 2>&1
then
        echo "This script requires rsync to be installed."
        echo "Please use your distribution's package manager to install rsync."
        exit 2
fi

if [ ! -d /mnt/backups ]; then
	sudo mkdir -p /mnt/backups || { echo "Failed to create /mnt/backups"; exit 3; }
	echo "No backup directory found at /mnt/backups. Creating one to use."
fi 

if [ ! -d /var/log/rsync ]; then
	sudo mkdir -p /var/log/rsync || { echo "Failed to create /var/log/rsync"; exit 4; }	
	echo "No rsync log directory in /var/log. Creating one to use."
fi


current_date=$(date +%Y-%m-%d)

rsync_options="-avb --backup-dir /mnt/backups/$current_date --delete"

echo "Starting backup of $1 to /mnt/backups/execDate-$current_date" >> /var/log/rsync/backup_$current_date.log
$(which rsync) $rsync_options $1 /mnt/backups/execDate-$current_date >> /var/log/rsync/backup_$current_date.log
