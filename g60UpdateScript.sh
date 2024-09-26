#!/bin/bash

# Function to send a Telegram notification
send_telegram_notification() {
    local message="$1"
    local api_token="${TELEGRAM_API_TOKEN:-$2}"
    local chat_id="${TELEGRAM_CHAT_ID:-$3}"
    local url="https://api.telegram.org/bot${api_token}/sendMessage"
    local parse_mode="HTML"

    if [[ -z "$api_token" || -z "$chat_id" ]]; then
        echo "Telegram API token or chat ID is not set. Cannot send notification." >&2
        return 1
    fi

    # Using curl to send a POST request to Telegram API
    curl -s -X POST "$url" -d chat_id="$chat_id" -d text="$message" -d parse_mode="$parse_mode" > /dev/null
    if [[ $? -ne 0 ]]; then
        echo "Failed to send notification via Telegram." >&2
        return 1
    fi
}

# Function to log messages
log_message() {
    local message="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" >> "$logfile"
}

# Main function to update system and send notifications
main() {
    local hostname=$(hostname)
    local date=$(date +%Y-%m-%d_%H-%M-%S)
    logfile="/var/log/autoupd/apt_upgrade_${hostname}_${date}.log"
    local status=0

    # Ensure necessary tools are available
    if ! command -v apt >/dev/null 2>&1; then
        echo "apt command not found. Exiting." >&2
        exit 1
    fi

    if ! command -v curl >/dev/null 2>&1; then
        echo "curl command not found. Exiting." >&2
        exit 1
    fi

    # Ensure the script can write to the log file
    mkdir /var/log/autoupd
    touch "$logfile" 2>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "Cannot write to log file: $logfile. Check file permissions." >&2
        exit 1
    fi

    # Define commands
    local apt_update_cmd="/usr/bin/apt update"
    local apt_upgrade_cmd="/usr/bin/apt -y upgrade"
    # Uncomment if cleanup is needed
    # local apt_cleanup_cmd="/usr/bin/apt -y autoremove && /usr/bin/apt autoclean"

    # Log start
    log_message "Starting update process"

    # Execute update commands and redirect output to logfile
    $apt_update_cmd >> "$logfile" 2>&1
    local update_status=$?
    log_message "Update command finished with status: $update_status"

    $apt_upgrade_cmd >> "$logfile" 2>&1
    local upgrade_status=$?
    log_message "Upgrade command finished with status: $upgrade_status"

    # Uncomment if cleanup is needed
    # $apt_cleanup_cmd >> $logfile 2>&1
    # local cleanup_status=$?
    # log_message "Cleanup command finished with status: $cleanup_status"

    # Check if any command failed
    if [[ $update_status -ne 0 || $upgrade_status -ne 0 ]]; then
        status=1
    fi

    # Log end
    log_message "Update process completed"

    # Check final status and send notification
    if [[ $status -eq 0 ]]; then
        send_telegram_notification "${hostname}: updated successfully." "${TELEGRAM_API_TOKEN}" "${TELEGRAM_CHAT_ID}"
    else
        send_telegram_notification "${hostname}: update failed. Check logs at ${logfile}" "${TELEGRAM_API_TOKEN}" "${TELEGRAM_CHAT_ID}"
    fi
}

# Set environment variables from arguments or fallback to defaults
TELEGRAM_API_TOKEN="7569452382:AAE0m-WlOGHa2oQeSOal6-3R8iz2TSECnjA"
TELEGRAM_CHAT_ID="-824488682"

# Execute main function
main
