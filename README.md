## Caution
**Caution**: This script has the potential to make significant changes to your server's configuration, which may lead to unexpected results or issues if not used correctly.

Before proceeding, please ensure that you have a backup of your server and that you understand the actions performed by this script. If you are not familiar with the tasks involved or are uncertain about any step, it is strongly recommended to seek guidance from a qualified system administrator or IT professional.

**The authors and maintainers of this script assume no liability for any damage or issues that may arise from its use. Use this script at your own risk**

# Comprehensive WireGuard VPN Setup Guide

This all-encompassing guide provides detailed steps for setting up a WireGuard VPN. The process begins with a general WireGuard setup, progresses to configuring the server side, and concludes with the client-side setup.

## Phase 1: WireGuard Installation and Initial Setup

### Description
Our `wireguard_setup.sh` script automates the installation and initial configuration of WireGuard and essential network utilities on Debian or Ubuntu systems.

### Requirements
- A Debian or Ubuntu system.
- Superuser privileges.
- Internet access for package downloading.

### Automated Tasks
1. Checks for root permissions.
2. Updates the system’s package list.
3. Upgrades all installed packages.
4. Installs WireGuard and additional network utilities.
5. Generates a pair of cryptographic keys for secure communication.

### Usage
#### Download the Setup Script
```bash
wget https://raw.githubusercontent.com/metishosting/wireguard-setup/main/wireguard_setup.sh
```

#### Make the Script Executable
```bash
sudo chmod +x wireguard_setup.sh
```

#### Execute the Script
```bash
sudo ./wireguard_setup.sh
```

#### Optional: Remove the Script After Setup
```bash
rm wireguard_setup.sh
```

## Phase 2: WireGuard Server Configuration

### Introduction
After setting up WireGuard, the next step involves configuring the VPN server. The `wireguard_server_setup.sh` script simplifies this by automating the installation and initial server settings.

### Prerequisites
- A server with any modern Linux distribution (adjustments may be necessary for specific distros).
- `wget` installed for script retrieval.
- Root or sudo access on the server.
- The public key from your WireGuard client.

### Usage
#### Download the Server Setup Script
```bash
wget https://raw.githubusercontent.com/metishosting/wireguard-setup/main/wireguard_server_setup.sh
```

#### Retrieve Client Information
On the WireGuard Client, execute:
```bash
sudo cat /etc/wireguard/publickey
```

#### Update the Server Setup Script
Open the script and replace the SERVER_PRIVATE_KEY with the data copied from the client.
```bash
sudo nano wireguard_server_setup.sh
```

#### Make the Script Executable
```bash
sudo chmod +x wireguard_server_setup.sh
```

#### Run the Server Setup Script
```bash
sudo ./wireguard_server_setup.sh
```

#### Optional: Remove the Script After Setup
```bash
rm wireguard_server_setup.sh
```

## Phase 3: WireGuard Client Configuration

### Overview
The final phase involves setting up the client-side of the VPN using `wireguard_client_setup.sh`, ensuring an error-free and consistent deployment process.

### Features
- **Superuser Privilege Check**: Script execution requires root permissions.
- **Private Key Verification**: Confirms the existence of the WireGuard private key before configuration.
- **Dynamic Configuration File Creation**: Assembles the WireGuard configuration file with user-specific details.
- **Immediate Service Activation**: Uses `systemd` to activate the WireGuard service after setup.
- **Fail-fast Mechanism**: Prevents potential system inconsistencies by halting operations upon any error.

### Usage
#### Download the Client Setup Script
```bash
wget https://raw.githubusercontent.com/metishosting/wireguard-setup/main/wireguard_client_setup.sh
```

#### Retrieve Server Information
Execute the following on the WireGuard server:
```bash
sudo cat /etc/wireguard/publickey
```
```bash
curl https://ipinfo.io/ip
```
```bash
sudo sed -n 's/.*ListenPort *= *\([^ ]*.*\)/\1/p' /etc/wireguard/wg0.conf
```

#### Update the Client Setup Script
Open the script, replacing placeholders with actual server data.
```bash
sudo nano wireguard_client_setup.sh
```

#### Make the Script Executable
```bash
sudo chmod +x wireguard_client_setup.sh
```

#### Run the Client Setup Script
```bash
sudo ./wireguard_client_setup.sh
```

#### Optional: Remove the Script After Setup
```bash
rm wireguard_client_setup.sh
```

## Phase 4: WireGuard Server Tunnel Firewall Setup Script

This will run the script and set up the WireGuard server tunnel firewall based on your edited configuration.

**Optional: Turn WireGuard into a 'Tunnel' Mode** (This step is optional)

By executing this script, you'll configure WireGuard to act as a secure tunnel, allowing encrypted traffic to pass through your server. This step is entirely optional and is used to enhance the security and privacy of your network traffic.

### Overview
This Bash script automates the setup of a secure WireGuard VPN server with an integrated firewall. It configures IP forwarding, resets and establishes firewall rules, forwards specific ports, and ensures the persistence of these settings. Additionally, the script installs iptables-persistent for rule management and enables the WireGuard service, simplifying the process of setting up a secure tunnel for your server.

### Usage
**Download the script from the specified URL using `wget`**:
```bash
wget https://raw.githubusercontent.com/metishosting/wireguard-setup/main/wireguard-server-tunnel-firewall.sh
```

**Edit the downloaded script to customize the `client_ssh_port` and `server_ssh_port` values**. You can use the `sudo nano` command to open the script in a text editor:
```bash
sudo nano wireguard-server-tunnel-firewall.sh
```

Inside the editor, find and modify the `client_ssh_port` and `server_ssh_port` values according to your requirements.

**Make the script executable using `chmod`**:
```bash
sudo chmod +x wireguard-server-tunnel-firewall.sh
```

**Execute the script with superuser privileges**:
```bash
sudo ./wireguard-server-tunnel-firewall.sh
```

**Optionally, if you no longer need the script, you can remove it using `rm`**:
```bash
sudo rm wireguard-server-tunnel-firewall.sh
```

This step is entirely optional and is used to delete the script file from your system if you no longer require it.

# Pterodactyl example

## Server
Allow pterodactyl port
```bash
sudo iptables -t nat -I PREROUTING 1 -d $SERVER_PUBLIC_IP -p tcp --dport 8443 -j DNAT --to-destination 10.0.0.2
```
Allow sftp port
```bash
sudo iptables -t nat -I PREROUTING 1 -d $SERVER_PUBLIC_IP -p tcp --dport 2022 -j DNAT --to-destination 10.0.0.2
```
Allow game server ports
```bash
sudo iptables -t nat -I PREROUTING 1 -d $SERVER_PUBLIC_IP -p tcp --dport 25555:26666 -j DNAT --to-destination 10.0.0.2
```
Allow udp game server ports
```bash
sudo iptables -t nat -I PREROUTING 2 -d $SERVER_PUBLIC_IP -p udp --dport 25555:26666 -j DNAT --to-destination 10.0.0.2
```
Allow port 80 (certbot)
```bash
sudo iptables -t nat -I PREROUTING 1 -d $SERVER_PUBLIC_IP -p tcp --dport 80 -j DNAT --to-destination 10.0.0.2
```
Save new firewall rules
```bash
iptables-save > /etc/iptables/rules.v4
```
## Client
Create a script that starts wireguard connection after 60 second
```bash
sudo nano /etc/systemd/system/delayed-wg-startup.service
```
Paste this
```bash
[Unit]
Description=Delayed Start for WireGuard interface
Requires=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'sleep 60 && /bin/systemctl start wg-quick@wg0'

[Install]
WantedBy=default.target
```
Reload systemd
```bash
sudo systemctl daemon-reload
```
Enable the service
```bash
sudo systemctl enable delayed-wg-startup.service
```

## Credit
- The initial script, which served as a basis for this guide, was created by [elitetheespeon](https://github.com/elitetheespeon). You can find the original script [here](https://github.com/elitetheespeon/scripts/blob/main/full_wg_tunnel_remote_example.sh).
