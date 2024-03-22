#!/bin/bash

# Check if the required number of arguments is provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 CONFIG_FILE DATE_OF_INTEREST"
    exit 1
fi

CONFIG_FILE="$1"
DATE_OF_INTEREST="$2"

# Check if the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found"
    exit 1
fi

# Read configuration file
AUTHOR=""
TIMEZONE=""
REPO_FOLDERS=()
while IFS='=' read -r key value; do
    case "$key" in
        "AUTHOR") AUTHOR="$value" ;;
        "TIMEZONE") TIMEZONE="$value" ;;
        "REPO_FOLDER") REPO_FOLDERS+=("$value") ;;
    esac
done < "$CONFIG_FILE"

# Check if AUTHOR and TIMEZONE are set
if [ -z "$AUTHOR" ] || [ -z "$TIMEZONE" ]; then
    echo "Error: AUTHOR or TIMEZONE not set in configuration file"
    exit 1
fi

# Adjust the DATE_OF_INTEREST to the developer's timezone
DATE_LOWER="$DATE_OF_INTEREST 00:00:00 $TIMEZONE"
DATE_UPPER="$DATE_OF_INTEREST 23:59:59 $TIMEZONE"

# Call list-commits-core.sh with the calculated dates and repositories
./list-commits-core.sh "$AUTHOR" "$DATE_LOWER" "$DATE_UPPER" "${REPO_FOLDERS[@]}"
