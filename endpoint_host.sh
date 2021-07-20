#! /bin/bash

# Set adequate firewall rules
ufw allow 22/tcp
ufw allow 51820/udp
ufw enable

# Installs and configures wireguard
apt update && apt install -y wireguard
umask 077
wg genkey | tee privatekey | wg pubkey > publickey

# Creates the wireguard config file with an interface, one peer for the permanent tunnel and one peer for the roadwarrior
private_key=$(cat privatekey)
main_iface="eth0"
ip_range="10.0.0.1/24"
wg0="
[Interface]\n
PrivateKey = $(echo $private_key)\n
Address = $(echo $ip_range), fd86:ea04:1115::1/64\n
ListenPort = 51820\n
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $(echo $main_iface) -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o $(echo $main_iface) -j MASQUERADE\n
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $(echo $main_iface) -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o $(echo $main_iface) -j MASQUERADE\n
SaveConfig = true\n
"
echo -e $wg0 > /etc/wireguard/wg0.conf

# Ensures ipv4 forwarding is permanently enabled
sed -i.bkp 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

# Enables the service so that it starts on boot
systemctl enable wg-quick@wg0