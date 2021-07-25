#!/bin/bash

usage(){
    echo "Configure your WireGuard tunnel endpoints"
    echo "\$1 host: server or client, default: client"
    echo "\$2 main interface name, default: eth0"
    echo "\$3 vpn ip range, default: 10.0.0.1/24"
}

select_interface(){
    all_interfaces=$(ip link | sed -n 's/\([0-9]\): \([a-z0-9]*\).*/\2/p')
    index=1
    echo "Select the interface used for traffic forwarding:"
    for interface in $all_interfaces 
    do
        echo "$index: $interface"
        let index=${index}+1
    done
    read number
    selected=$(echo $all_interfaces | cut -d" " -f$(echo $number))
}

select_ip_range(){
    echo "Enter the IP range for your VPN:"
    read ip_range
}

# select_interface
# echo "selected $selected"

usage

# TODO:
# configure $ip_range