#!/bin/bash

# Enable strict bash mode. Abort if any command exits with a non-zero status.
set -euo pipefail

echo "Starting the WireGuard client setup script..."

# Ensure the script is run with superuser privileges
if [ "$(id -u)" -ne 0 ]; then 
    echo "Error: This script must be run as root!"
    exit 1
fi

# Variables to be replaced with the user's server details
SERVER_PUBLIC_KEY="your_server_public_key"
SERVER_PUBLIC_IP="your_server_public_ip"
SERVER_PORT="your_server_port"

# Check for the existence of the WireGuard private key and read it
echo "Checking for WireGuard private key..."
PRIVATE_KEY_PATH="/etc/wireguard/privatekey"
if [ ! -f "$PRIVATE_KEY_PATH" ]; then
    echo "Error: Missing WireGuard private key at $PRIVATE_KEY_PATH."
    exit 1
fi
CLIENT_PRIVATE_KEY=$(cat "$PRIVATE_KEY_PATH")

# Create the WireGuard configuration file using the provided details
echo "Creating WireGuard configuration file..."
CONFIG_PATH="/etc/wireguard/wg0.conf"
cat <<EOT > "$CONFIG_PATH"
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
# Set the internal IP address of the VPN client; may require customization
Address = 10.0.0.2/24
# Using Cloudflare's DNS server; can be replaced with a preferred DNS provider
DNS = 1.1.1.1
MTU = 1500

[Peer]
# Configuration details of the VPN server
PublicKey = $SERVER_PUBLIC_KEY
# Reroute all traffic through the VPN
AllowedIPs = 0.0.0.0/0
# Server's public endpoint
Endpoint = $SERVER_PUBLIC_IP:$SERVER_PORT
# Keepalive (use if you're behind NAT)
PersistentKeepalive = 25
EOT

# Start the WireGuard service
echo "Attempting to start WireGuard..."
if systemctl start wg-quick@wg0; then
    echo "WireGuard started successfully."
else
    echo "Failed to start WireGuard. Please check the system logs for more details."
    exit 1
fi

echo "WireGuard client setup is complete. Please verify the connection status."
systemctl reboot
