#!/bin/bash

# This script will set up wireguard and necessary tools.
# It must be run with superuser privileges.

# Inform the user the script has started.
echo "Starting the setup script."

# Ensure the script is running with root permissions.
if [ $(id -u) -ne 0 ]; then 
    echo "Please run this script as root or use sudo."
    exit 1 
else
    echo "Script is running as root. Proceeding with setup."
fi

# 'set -e' tells bash to exit the script if any command fails.
set -e

# Update the package lists for upgrades for packages that need upgrading.
echo "Updating system package information..."
apt update

# Upgrade all the installed packages to their latest version.
echo "Upgrading system packages to their latest versions..."
apt upgrade -y

# Install necessary packages for the wireguard and other network tools.
echo "Installing required tools (wireguard, resolvconf, tcpdump, net-tools, iptables)..."
apt install -y wireguard resolvconf tcpdump net-tools iptables

# Navigate to the wireguard directory to perform operations.
cd /etc/wireguard/

# Generate the private and public keys for wireguard.
echo "Generating wireguard keys..."
wg genkey | tee privatekey | wg pubkey > publickey

# Inform the user that the keys have been generated.
echo "Wireguard keys generated successfully."

# 'set +e' reverses 'set -e' and tells bash to continue the script even if errors occur.
set +e

# End of the script message.
echo "Setup script execution completed."
