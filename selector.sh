#!/bin/bash

usage(){
    echo "Configure your WireGuard tunnel endpoints"
    echo "TODO"
    echo "TODO"
    echo "TODO"
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

select_interface
echo "selected $selected"

# TODO:
# configure $ip_range