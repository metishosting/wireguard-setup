#!/bin/bash

# Display a message indicating the start of the WireGuard client setup script
echo "Starting the WireGuard server tunnel firewall setup script..."

# Ensure the script is run with superuser privileges
if [ "$(id -u)" -ne 0 ]; then 
    echo "Error: This script must be run as root!"
    exit 1
fi

# Define server network interface and SSH port variables
WIREGUARD_PORT=$(sed -n 's/.*ListenPort *= *\([^ ]*.*\)/\1/p' /etc/wireguard/wg0.conf)
SERVER_PUBLIC_IP=$(curl -s ipinfo.io/ip)
SERVER_NETWORK_INTERFACE=$(ip -br link show | awk '{if ($1 != "lo" && !($1 ~ /virbr/)) {print $1; exit}}')
CLIENT_SSH_PORT="223" # Change this to whatever you want
SERVER_SSH_PORT="22" # Change this to SSH port this server is running

# Check if the IP retrieval was successful
if [ -n "$SERVER_PUBLIC_IP" ]; then
  echo "External IP: $SERVER_PUBLIC_IP" # Corrected variable name
else
  echo "Error: Failed to retrieve external IP."
  exit 1
fi

# Enable IP forwarding for IPv4 and IPv6
echo "Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1

# Uncomment the following lines in sysctl.conf to make IP forwarding persistent
echo "Updating sysctl.conf to make IP forwarding persistent..."
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/' /etc/sysctl.conf

echo "Flushing existing iptables rules..."

# Flush all existing iptables rules and delete custom chains
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

echo "Setting default policies to ACCEPT..."

# Disallow all incomming and forwarding because we dont trust it
iptables -P INPUT DROP
iptables -P FORWARD DROP

# Allow all outgoing traffic from server because we trust it
iptables -P OUTPUT ACCEPT

# Display a message indicating the completion of the iptables reset
echo "iptables rules reset to default settings."

# Set up iptables rules
echo "Setting up iptables rules..."

# Reroute traffic recieved from the server interface to wireguard interface
iptables -I INPUT 1 -i wg0 -j ACCEPT
iptables -I FORWARD 1 -i wg0 -j ACCEPT
iptables -I FORWARD 1 -i $SERVER_NETWORK_INTERFACE -o wg0 -j ACCEPT
iptables -t nat -I POSTROUTING 1 -o $SERVER_NETWORK_INTERFACE -j MASQUERADE

# Allow wireguard connections to the server interface
iptables -I INPUT 1 -i $SERVER_NETWORK_INTERFACE -p udp --dport $WIREGUARD_PORT -j ACCEPT

# Allow loopback device
iptables -I INPUT 1 -i lo -j ACCEPT

# Allow already active connections
iptables -I INPUT 1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Drop invalid packets
iptables -I INPUT 1 -m conntrack --ctstate INVALID -j DROP

# Allow SSH
iptables -I INPUT 1 -p tcp --dport $SERVER_SSH_PORT -j ACCEPT

# Forward specific ports from the server to the client
echo "Forwarding specific ports from the server to the client..."
iptables -t nat -I PREROUTING 1 -d $SERVER_PUBLIC_IP -p tcp --dport $CLIENT_SSH_PORT -j DNAT --to-destination 10.0.0.2

# Install iptables-persistent to save iptables rules
echo "Installing iptables-persistent to save rules..."
apt-get update
apt-get install -y iptables-persistent
iptables-save > /etc/iptables/rules.v4

# Start the Wireguard service
echo "Starting the Wireguard service..."
systemctl enable --now wg-quick@wg0

# Display a message indicating the completion of the script
echo "WireGuard server tunnel firewall setup completed."
