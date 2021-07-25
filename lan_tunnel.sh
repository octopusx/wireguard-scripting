#! /bin/bash

usage(){
    echo "Configure your WireGuard tunnel endpoints"
    echo "\$1 host: server or client, default: client"
    echo "\$2 main interface name, default: eth0"
    echo "\$3 vpn ip range, default: 10.0.0.1/24"
}

# Installs and configures wireguard
apt update && apt install -y wireguard
umask 077
wg genkey | tee privatekey | wg pubkey > publickey

# Creates wireguard config file that contains the correctly configured interface and the remote server peer, with config for 20s heartbeat to keep the tunnel up
# TODO: actually adapt the following block to this endpoint
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