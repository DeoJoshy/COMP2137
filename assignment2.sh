#!/bin/bash

# Update and install required software
sudo apt update
sudo apt install -y apache2 squid ufw

# Configure netplan for 192.168.16 network interface
NETPLAN_FILE="/etc/netplan/00-installer-config.yaml"
IP_ADDRESS="192.168.16.21/24"
NETPLAN_CONFIG="network:
  ethernets:
    eth1:
      addresses:
        - $IP_ADDRESS
      dhcp4: false
  version: 2"
echo -e "$NETPLAN_CONFIG" | sudo tee $NETPLAN_FILE
sudo netplan apply

# Update /etc/hosts
sudo sed -i '/server1/d' /etc/hosts
echo "192.168.16.21 server1" | sudo tee -a /etc/hosts

# Configure UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow in on eth1 to any port 22
sudo ufw allow http
sudo ufw allow in on eth1 to any port 3128 # Squid default port
sudo ufw enable

# Create user accounts with SSH keys
USERS=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")
for user in "${USERS[@]}"; do
  if ! id -u "$user" >/dev/null 2>&1; then
    sudo adduser --disabled-password --gecos "" "$user"
  fi
  sudo mkdir -p /home/$user/.ssh
  sudo chown $user:$user /home/$user/.ssh
  sudo chmod 700 /home/$user/.ssh
done

# Add SSH keys for dennis
sudo usermod -aG sudo dennis
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" | sudo tee -a /home/dennis/.ssh/authorized_keys

echo "Script execution completed successfully."
