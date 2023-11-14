#!/bin/bash

# This script configures a basic WireGuard VPN server.

echo "Starting the WireGuard configuration script..."

# Ensure the script is being run as root
if [ "$(id -u)" != "0" ]; then
    echo "Error: This script must be run as root!"
    exit 1
fi

# Pre-defined variables
CLIENT_PUBLIC_KEY="your_client_public_key" # Replace with your client's actual public key
SERVER_PORT="51820" # It's a good practice to use a non-default port

echo "Verifying WireGuard installation..."

# Check if WireGuard is installed
if ! [ -x "$(command -v wg)" ]; then
  echo 'Error: WireGuard is not installed.' >&2
  exit 1
fi

echo "Checking for existing WireGuard private key..."

# Check for the presence of the server's private key
if [ ! -f /etc/wireguard/privatekey ]; then
    echo "Error: Private key not found. Cannot proceed with the configuration."
    exit 1
fi
SERVER_PRIVATE_KEY=$(cat /etc/wireguard/privatekey)

echo "Creating WireGuard server configuration..."

# Here we create a WireGuard configuration file. 
# Be sure to replace placeholders with actual network settings suitable for your environment.
cat <<EOT > /etc/wireguard/wg0.conf
[Interface]
Address = 10.0.0.1/24
ListenPort = $SERVER_PORT
PrivateKey = $SERVER_PRIVATE_KEY

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = 10.0.0.2/32
EOT

# We must enable IP forwarding for VPN functionality
echo "Enabling IP forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward

# Make IP forwarding changes persistent across reboots
echo "Making IP forwarding persistent..."
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

# Activating the WireGuard service with the created configuration
echo "Starting and enabling WireGuard..."
systemctl enable --now wg-quick@wg0

# Final success message
echo "WireGuard is now configured and running. Test the setup by connecting from a client device."

# Note: Script users should still validate their network and firewall settings, ensuring the VPN server is accessible.
