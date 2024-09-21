#!/bin/bash

echo "samsung-m12" >/etc/hostname

cat <<EOF >/etc/hosts
127.0.0.1   localhost
127.0.1.1   samsung-m12

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

ln -fs /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
dpkg-reconfigure -f noninteractive tzdata
locale-gen en_US.UTF-8

cat <<EOF >/etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
    rndis0:
      dhcp4: no
      addresses:
        - 192.168.137.2/24
      gateway4: 192.168.137.1
      nameservers:
        addresses:
          - 8.8.8.8
EOF

useradd -m -s /bin/bash vietnhat
echo "vietnhat:vietnhat02" | chpasswd
echo "root:vietnhat02" | chpasswd

# Grant 'vietnhat' sudo privileges
usermod -aG sudo vietnhat

# Set permissions for the 'vietnhat' home directory
chown -R vietnhat:vietnhat /home/vietnhat
chmod 755 /home/vietnhat

# Ensure root has full permissions for the root directory (which is the default)
chown -R root:root /root
chmod 700 /root

# Fix ownership of root directory (/)
chown root:root /

apt install -y openssh-server

cat <<EOF >>/etc/ssh/sshd_config
# Custom SSH server configuration
PermitRootLogin no                # Disable root login via SSH
PasswordAuthentication yes        # Enable password authentication
AllowUsers vietnhat               # Only allow 'vietnhat' to log in via SSH
PubkeyAuthentication yes          # Enable public key authentication
PermitEmptyPasswords no           # Disallow empty passwords
ChallengeResponseAuthentication no
UsePAM yes
EOF

# Install common packages
apt install -y \
    build-essential \
    curl \
    wget \
    git \
    vim \
    nano \
    sudo \
    net-tools \
    htop \
    unzip \
    software-properties-common \
    ufw

# Optionally, start and enable the firewall (UFW)
ufw allow OpenSSH
ufw enable

# Optionally, start and enable the SSH service
systemctl enable ssh
systemctl start ssh

cd /home/vietnhat
git clone https://github.com/Vi631/android_vendor_samsung_m12.git
cd /home/vietnhat/android_vendor_samsung_m12
mkdir /lib/firmware
cp -r ./etc/* /lib/firmware/
cp -r ./lib64/* /lib/
cd /home/vietnhat
rm -r android_vendor_samsung_m12
