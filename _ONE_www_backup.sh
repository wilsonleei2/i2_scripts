#!/bin/bash

# Enter one of project name
projects="iaacad9"

# Backup directory
backup_dir="/backup"

# Create backup directory if it doesn't exist
mkdir -p "$backup_dir"

# Get current date and time
datetime=$(date +"%Y%m%d_%H%M%S")

# Backup each project
for project in $projects; do
    source_dir="/var/www/$project"

    # # Create zip archive
    # backup_file="$backup_dir/${project}--${datetime}.zip"
    # zip -r "$backup_file" "$source_dir" -x "*.zip" -x "*.gz" -x "*.sql" -x "*.bz2" -x "*.apk" -x "*.mp4"

    # echo "Backup created for $project: $backup_file"

    # OR 
    # Create tar archive
    backup_file="$backup_dir/${project}--${datetime}.tar.gz"
    tar -czf "$backup_file" --exclude="*.zip" --exclude="*.gz" --exclude="*.sql" --exclude="*.bz2" --exclude="*.apk" --exclude="*.mp4" "$source_dir"

    echo "Backup created for $project: $backup_file"
done

echo "Nginx files backup completed."
