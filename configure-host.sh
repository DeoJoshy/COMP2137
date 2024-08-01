#!/bin/bash

verbose=false
log() {
    if [ "$verbose" = true ]; then
        echo "$1"
    fi
}

trap "" TERM HUP INT

update_hostname() {
    local desiredName=$1
    local currentName=$(hostname)
    if [ "$currentName" != "$desiredName" ]; then
        log "Changing hostname from $currentName to $desiredName"
        echo "$desiredName" > /etc/hostname
        sed -i "s/$currentName/$desiredName/g" /etc/hosts
        hostnamectl set-hostname "$desiredName"
        logger "Hostname changed from $currentName to $desiredName"
    else
        log "Hostname is already set to $desiredName"
    fi
}

update_ip() {
    local desiredIP=$1
    local currentIP=$(hostname -I | awk '{print $1}')
    if [ "$currentIP" != "$desiredIP" ]; then
        log "Changing IP address from $currentIP to $desiredIP"
        sed -i "s/$currentIP/$desiredIP/g" /etc/hosts
        sed -i "s/$currentIP/$desiredIP/g" /etc/netplan/*.yaml
        netplan apply
        logger "IP address changed from $currentIP to $desiredIP"
    else
        log "IP address is already set to $desiredIP"
    fi
}

update_hostentry() {
    local desiredName=$1
    local desiredIP=$2
    if grep -q "$desiredName" /etc/hosts; then
        sed -i "s/.*$desiredName/$desiredIP $desiredName/g" /etc/hosts
        log "Updated /etc/hosts entry for $desiredName"
    else
        echo "$desiredIP $desiredName" >> /etc/hosts
        log "Added /etc/hosts entry for $desiredName"
    fi
    logger "/etc/hosts entry updated for $desiredName with IP $desiredIP"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -verbose)
            verbose=true
            shift
            ;;
        -name)
            update_hostname "$2"
            shift 2
            ;;
        -ip)
            update_ip "$2"
            shift 2
            ;;
        -hostentry)
            update_hostentry "$2" "$3"
            shift 3
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done
