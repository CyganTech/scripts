#!/bin/bash

# Variables
SCRIPT_URL="https://raw.githubusercontent.com/CyganTech/scripts/refs/heads/main/g60UpdateScript.sh"
SCRIPT_DEST="/usr/local/bin/g60UpdateScript.sh"
LOG_DIR="/var/log/autoupd"

# Step 1: Download the script to the correct directory
echo "Downloading script from $SCRIPT_URL..."
curl -o $SCRIPT_DEST $SCRIPT_URL

# Step 2: Make the script executable
echo "Making the script executable..."
chmod +x $SCRIPT_DEST

# Step 3: Create the log directory if it doesn't exist
if [ ! -d "$LOG_DIR" ]; then
    echo "Creating log directory at $LOG_DIR..."
    mkdir -p "$LOG_DIR"
fi

# Step 4: Generate a random minute (0-59) for the cron job
RANDOM_MINUTE=$(shuf -i 0-59 -n 1)

# Step 5: Add the cron job
echo "Adding cron job to crontab to run at $RANDOM_MINUTE minute of 8pm every Sunday..."
(crontab -l 2>/dev/null; echo "$RANDOM_MINUTE 20 * * 0 $SCRIPT_DEST > /dev/null 2>&1") | crontab -

echo "Installation complete! The script will run at $RANDOM_MINUTE minute(s) past 8pm every Sunday."
