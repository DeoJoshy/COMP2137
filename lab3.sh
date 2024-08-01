#!/bin/bash
# This script runs the configure-host.sh script from the current directory to modify 2 servers and update the local /etc/hosts file

verbose=false

# Check if verbose mode is enabled
if [[ $1 == "-verbose" ]]; then
    verbose=true
    shift
fi

# Define the servers and configurations
servers=("server1-mgmt" "server2-mgmt")
names=("loghost" "webhost")
ips=("192.168.16.3" "192.168.16.4")

# Transfer and run the configure-host.sh script on each server
for i in ${!servers[@]}; do
    server=${servers[$i]}
    name=${names[$i]}
    ip=${ips[$i]}
    scp configure-host.sh remoteadmin@$server:/root
    if [ "$verbose" = true ]; then
        ssh remoteadmin@$server "sudo /root/configure-host.sh -verbose -name $name -ip $ip -hostentry ${names[1-$i]} ${ips[1-$i]}"
    else
        ssh remoteadmin@$server "sudo /root/configure-host.sh -name $name -ip $ip -hostentry ${names[1-$i]} ${ips[1-$i]}"
    fi
done

# Update local /etc/hosts file
sudo ./configure-host.sh -hostentry loghost 192.168.16.3
sudo ./configure-host.sh -hostentry webhost 192.168.16.4
