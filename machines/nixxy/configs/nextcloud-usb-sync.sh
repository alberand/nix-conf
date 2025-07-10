#!/usr/bin/env bash

set -e

DIR_A="/mnt/nextcloud/USB"
DIR_B="/mnt/usb"

if [ ! -d "$DIR_A" ]; then
    echo "Error: Source directory '$DIR_A' does not exist"
    exit 1
fi

if [ ! -d "$DIR_B" ]; then
    echo "Error: Source directory '$DIR_B' does not exist"
    exit 1
fi

# Get current date in YYYY-MM-DD format
CURRENT_DATE=$(date +%Y-%m-%d)
BACKUP_DIR="$DIR_A/zzz_$CURRENT_DATE"

# Check if there are any non-backup files/directories in DIR_A
NON_BACKUP_COUNT=$(find "$DIR_A" -maxdepth 1 -type f -o \( -type d -maxdepth 1 ! -name "zzz_*" ! -path "$DIR_A" \) | wc -l)

if [ "$NON_BACKUP_COUNT" -eq 0 ]; then
    echo "No files or directories to backup/move in '$DIR_A' (only backup directories found)"
    echo "Exiting without performing any operations"
    exit 0
fi

echo "Starting backup process..."
echo "Source directory: $DIR_A"
echo "Backup directory: $BACKUP_DIR"
echo "Destination directory: $DIR_B"
echo "Found $NON_BACKUP_COUNT items to backup/move"

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
else
    echo "Backup directory already exists: $BACKUP_DIR"
fi

# Copy all content from DIR_A to backup directory, excluding backup directories
echo "Copying files to backup directory..."

# Use find to get all files and directories in DIR_A, excluding backup dirs
find "$DIR_A" -maxdepth 1 -type f -o \( -type d -maxdepth 1 ! -name "zzz_*" ! -path "$DIR_A" \) | while read -r item; do
    echo "Copying: $(basename "$item")"
    mv "$item" "$BACKUP_DIR/"
done

echo "Backup completed successfully!"

echo "Removing files from: $DIR_B"
rm -rf /mnt/usb/*
touch "$DIR_B/flash.lock"

# Move content from DIR_A to DIR_B (excluding backup directories)
echo "Moving files from $BACKUP_DIR to $DIR_B..."

# Find all items in DIR_A except backup directories
find "$BACKUP_DIR" -maxdepth 1 -type f | while read -r item; do
    if [ -f "$item" ]; then
        # It's a file
        echo "Moving file: $(basename "$item")"
        cp "$item" "$DIR_B/"
    elif [ -d "$item" ]; then
        # It's a directory (not a backup dir)
        echo "Moving directory: $(basename "$item")"
        cp "$item" "$DIR_B/"
    fi
done

echo "Move operation completed successfully!"
echo "Summary:"
echo "- Backup created in: $BACKUP_DIR"
echo "- Content moved to: $DIR_B"
echo "- Backup directories (zzz_*) remain in: $DIR_A"
