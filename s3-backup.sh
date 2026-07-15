#!/bin/bash

############################################
# S3 Backup Script
############################################

# Variables
BUCKET_NAME="testbucket-5566"
BACKUP_DIR="/opt/s3backup/backups"
LOG_DIR="/opt/s3backup/logs"
TEMP_DIR="/opt/s3backup/temp"

DATE=$(date +"%Y%m%d_%H%M%S")

ZIP_FILE="$BACKUP_DIR/s3_backup_$DATE.zip"
LOG_FILE="$LOG_DIR/s3_backup_$DATE.log"

echo "===================================" >> "$LOG_FILE"
echo "S3 Backup Started : $(date)" >> "$LOG_FILE"
echo "Bucket : $BUCKET_NAME" >> "$LOG_FILE"
echo "===================================" >> "$LOG_FILE"

# Clean temp directory
rm -rf "$TEMP_DIR"/*
mkdir -p "$TEMP_DIR"

echo "Downloading files from S3..." >> "$LOG_FILE"

aws s3 sync s3://$BUCKET_NAME "$TEMP_DIR" >> "$LOG_FILE" 2>&1

if [ $? -ne 0 ]; then
    echo "S3 Download Failed!" >> "$LOG_FILE"
    exit 1
fi

echo "Creating ZIP Backup..." >> "$LOG_FILE"

zip -r "$ZIP_FILE" "$TEMP_DIR" >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    echo "Backup Created Successfully" >> "$LOG_FILE"
else
    echo "ZIP Creation Failed" >> "$LOG_FILE"
    exit 1
fi

SIZE=$(du -sh "$ZIP_FILE" | awk '{print $1}')

echo "Backup File : $ZIP_FILE" >> "$LOG_FILE"
echo "Backup Size : $SIZE" >> "$LOG_FILE"

echo "Backup Completed : $(date)" >> "$LOG_FILE"
#########################################
# Keep only the latest 7 ZIP backups
#########################################

echo "Starting backup rotation..." >> "$LOG_FILE"

find "$BACKUP_DIR" -type f -name "*.zip" | sort | head -n -7 | while read OLD_ZIP
do
    BASE=$(basename "$OLD_ZIP" .zip)

    echo "Deleting old backup: $BASE.zip" >> "$LOG_FILE"

    rm -f "$OLD_ZIP"

    rm -f "$LOG_DIR/$BASE.log"

    echo "Deleted log: $BASE.log" >> "$LOG_FILE"
done

echo "Rotation Completed" >> "$LOG_FILE"

echo "===================================" >> "$LOG_FILE"