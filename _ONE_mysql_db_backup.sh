#!/bin/bash

# Enter one of database name
projects="iaacad9"

# Backup directory
backup_dir="/backup"

# MySQL credentials file
mysql_creds_file="/root/_i2_sh_script/mysql_credentials.cnf"

# Create backup directory if it doesn't exist
mkdir -p "$backup_dir"

# Get current date and time
datetime=$(date +"%Y%m%d_%H%M%S")

# Backup each database
for db in $projects; do
    backup_file="$backup_dir/${db}--${datetime}.sql"
    temp_full_backup="/tmp/${db}_full_backup.sql"
    temp_cache_structure="/tmp/${db}_cache_structure.sql"

    # Get list of cache tables & 'watchdog'
    cache_tables=$(mysql --defaults-extra-file="$mysql_creds_file" -N -e "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='$db' AND (TABLE_NAME LIKE 'cache_%' OR TABLE_NAME = 'watchdog');")

    # Prepare ignore table arguments for full backup
    ignore_tables=""
    for table in $cache_tables; do
        ignore_tables="$ignore_tables --ignore-table=$db.$table"
    done

    # Perform full database dump (excluding cache tables)
    # mysqldump --defaults-extra-file="$mysql_creds_file" $ignore_tables "$db" >"$temp_full_backup"
    mysqldump --defaults-extra-file="$mysql_creds_file" --single-transaction --no-tablespaces $ignore_tables "$db" >"$temp_full_backup"

    # Dump only the structure of cache tables
    if [ -n "$cache_tables" ]; then
        # mysqldump --defaults-extra-file="$mysql_creds_file" --no-data "$db" $cache_tables >"$temp_cache_structure"
        mysqldump --defaults-extra-file="$mysql_creds_file" --no-data --no-tablespaces "$db" $cache_tables >"$temp_cache_structure"
    else
        touch "$temp_cache_structure" # Create an empty file if no cache tables
    fi

    # Combine the full backup and cache table structures
    cat "$temp_full_backup" "$temp_cache_structure" >"$backup_file"

    # Clean up temporary files
    rm "$temp_full_backup" "$temp_cache_structure"

    echo "Backup created for database $db: $backup_file"
done

echo "MySQL database backup completed."
