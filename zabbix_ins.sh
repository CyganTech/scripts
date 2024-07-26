#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Update package index
apt-get update

# Install the required packages
apt-get install -y wget apt-transport-https gnupg

# Download Zabbix 7.0 repository configuration
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu22.04_all.deb

# Install the downloaded package
dpkg -i zabbix-release_7.0-2+ubuntu22.04_all.deb

# Update package index with the new Zabbix repository
apt update

# Install Zabbix agent
apt install -y zabbix-agent

# Set the configuration parameters
sed -i 's/^Server=.*$/Server=192.168.112.8/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/^ServerActive=.*$/ServerActive=192.168.112.8/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/^# HostnameItem=.*$/HostnameItem=system.hostname/' /etc/zabbix/zabbix_agentd.conf

# Restart Zabbix agent
systemctl restart zabbix-agent

# Enable Zabbix agent on startup
systemctl enable zabbix-agent

# Remove the downloaded Zabbix repository configuration package
rm -f zabbix-release_7.0-2+ubuntu22.04_all.deb

# Add firewall rule for Zabbix agent (default port: 10050)
ufw allow 10050/tcp

echo "Zabbix agent 6.0 installed and configured successfully."
